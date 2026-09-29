import AppKit

struct ActionExecutionResult: Sendable {
    let message: String
    let isError: Bool
}

@MainActor
final class ScheduledActionExecutor {
    private let discoveryService: AppDiscoveryService

    init(discoveryService: AppDiscoveryService) {
        self.discoveryService = discoveryService
    }

    func execute(_ plan: SchedulePlan) async -> ActionExecutionResult {
        switch plan.action {
        case .quitApplications:
            return await closeApplications(matching: plan.targets)
        case .shutDown:
            return requestSystemShutdown()
        }
    }

    private func closeApplications(matching targets: [ApplicationTarget]) async -> ActionExecutionResult {
        let applications = discoveryService.runningApplications().filter { application in
            targets.contains { target in
                if let bundleIdentifier = target.bundleIdentifier {
                    return application.bundleIdentifier == bundleIdentifier
                }
                return application.processIdentifier == target.processIdentifier
            }
        }

        guard !applications.isEmpty else {
            return ActionExecutionResult(message: "所选应用已不在运行", isError: false)
        }

        var requestedCount = 0
        for item in applications where item.application.terminate() {
            requestedCount += 1
        }

        // Give apps a moment to save state and quit gracefully before forcing them.
        try? await Task.sleep(for: .seconds(3))

        var forcedCount = 0
        for item in applications where !item.application.isTerminated {
            if item.application.forceTerminate() {
                forcedCount += 1
            }
        }

        if requestedCount == 0 && forcedCount == 0 {
            return ActionExecutionResult(message: "无法关闭所选应用", isError: true)
        }

        let suffix = forcedCount > 0 ? "，其中 \(forcedCount) 个被强制关闭" : ""
        return ActionExecutionResult(
            message: "已处理 \(applications.count) 个应用\(suffix)",
            isError: false
        )
    }

    private func requestSystemShutdown() -> ActionExecutionResult {
        let script = NSAppleScript(source: "tell application \"System Events\" to shut down")
        var error: NSDictionary?
        script?.executeAndReturnError(&error)

        if let error {
            let message = error[NSAppleScript.errorMessage] as? String ?? "系统拒绝了关机请求"
            return ActionExecutionResult(message: message, isError: true)
        }

        return ActionExecutionResult(message: "已向系统发送关机请求", isError: false)
    }
}
