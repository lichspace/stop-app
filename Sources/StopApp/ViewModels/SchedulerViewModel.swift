import AppKit
import Combine
import Foundation

@MainActor
final class SchedulerViewModel: NSObject, ObservableObject {
    @Published var action: ScheduledAction = .quitApplications
    @Published var durationSelectionMinutes = 15
    @Published var manualMinutesText = "30"
    @Published var searchText = ""
    @Published private(set) var runningApplications: [RunningApplicationItem] = []
    @Published private(set) var selectedApplicationIDs = Set<String>()
    @Published private(set) var scheduledPlan: SchedulePlan?
    @Published private(set) var remainingText = ""
    @Published private(set) var statusMessage: String?
    @Published private(set) var statusIsError = false
    @Published private(set) var isExecuting = false

    private let discoveryService: AppDiscoveryService
    private let executor: ScheduledActionExecutor
    private var timer: Timer?

    override init() {
        let discoveryService = AppDiscoveryService()
        self.discoveryService = discoveryService
        executor = ScheduledActionExecutor(discoveryService: discoveryService)
        super.init()

        refreshApplications()
        observeWorkspaceChanges()
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    var filteredApplications: [RunningApplicationItem] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return runningApplications
        }
        return runningApplications.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || ($0.bundleIdentifier?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var selectedApplications: [RunningApplicationItem] {
        runningApplications.filter { selectedApplicationIDs.contains($0.id) }
    }

    var proposedFireDate: Date {
        ScheduleDateCalculator.date(afterMinutes: selectedDurationMinutes ?? 0, now: Date())
    }

    var validationMessage: String? {
        if durationSelectionMinutes == 0 {
            guard let minutes = selectedDurationMinutes else {
                return "请输入有效的分钟数"
            }
            guard minutes > 0 else {
                return "分钟数必须大于 0"
            }
            guard minutes <= 10_080 else {
                return "最长可设置 7 天（10080 分钟）"
            }
        }
        return proposedPlan.validationMessage(relativeTo: Date())
    }

    var selectedDurationMinutes: Int? {
        if durationSelectionMinutes > 0 {
            return durationSelectionMinutes
        }
        return Int(manualMinutesText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var durationSummary: String {
        guard let minutes = selectedDurationMinutes, minutes > 0 else {
            return "等待输入时长"
        }
        return "将在 \(DurationTextFormatter.readable(minutes: minutes))后执行"
    }

    var canSchedule: Bool {
        scheduledPlan == nil && !isExecuting && validationMessage == nil
    }

    var primaryButtonTitle: String {
        action == .quitApplications ? "开始计时" : "安排关机"
    }

    func toggleSelection(for application: RunningApplicationItem) {
        if selectedApplicationIDs.contains(application.id) {
            selectedApplicationIDs.remove(application.id)
        } else {
            selectedApplicationIDs.insert(application.id)
        }
    }

    func refreshApplications() {
        runningApplications = discoveryService.runningApplications()
    }

    func schedule() {
        let plan = proposedPlan
        guard let message = plan.validationMessage(relativeTo: Date()) else {
            scheduledPlan = plan
            statusMessage = nil
            statusIsError = false
            updateRemainingText()
            startTimer()
            return
        }

        statusMessage = message
        statusIsError = true
    }

    func cancelSchedule() {
        timer?.invalidate()
        timer = nil
        scheduledPlan = nil
        remainingText = ""
        statusMessage = "已取消定时任务"
        statusIsError = false
    }

    private var proposedPlan: SchedulePlan {
        SchedulePlan(
            action: action,
            targets: selectedApplications.map(\.target),
            fireDate: proposedFireDate
        )
    }

    private func observeWorkspaceChanges() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(
            self,
            selector: #selector(workspaceApplicationsDidChange),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        center.addObserver(
            self,
            selector: #selector(workspaceApplicationsDidChange),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )
    }

    @objc private func workspaceApplicationsDidChange() {
        refreshApplications()
    }

    private func startTimer() {
        timer?.invalidate()
        let timer = Timer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(timerDidFire),
            userInfo: nil,
            repeats: true
        )
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc private func timerDidFire() {
        guard let plan = scheduledPlan else {
            timer?.invalidate()
            timer = nil
            return
        }

        if plan.fireDate <= Date() {
            timer?.invalidate()
            timer = nil
            scheduledPlan = nil
            remainingText = ""
            isExecuting = true

            Task { @MainActor [weak self] in
                guard let self else { return }
                let result = await executor.execute(plan)
                isExecuting = false
                statusMessage = result.message
                statusIsError = result.isError
                refreshApplications()
            }
        } else {
            updateRemainingText()
        }
    }

    private func updateRemainingText() {
        guard let plan = scheduledPlan else {
            remainingText = ""
            return
        }

        let totalSeconds = Int(ceil(plan.remainingTime(relativeTo: Date())))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            remainingText = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            remainingText = String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
