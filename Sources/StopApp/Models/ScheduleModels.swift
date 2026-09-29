import Foundation

enum ScheduledAction: String, CaseIterable, Identifiable, Sendable {
    case quitApplications
    case shutDown

    var id: Self { self }

    var title: String {
        switch self {
        case .quitApplications: "关闭应用"
        case .shutDown: "关闭电脑"
        }
    }

    var systemImage: String {
        switch self {
        case .quitApplications: "xmark.app"
        case .shutDown: "power"
        }
    }
}

struct DurationOption: Identifiable, Hashable, Sendable {
    let minutes: Int

    var id: Int { minutes }

    var title: String {
        "\(minutes) 分钟"
    }

    static let menuOptions = [5, 10, 15, 20, 25, 30, 40, 50, 60].map(DurationOption.init)
}

enum DurationTextFormatter {
    static func readable(minutes: Int) -> String {
        guard minutes >= 60 else {
            return "\(minutes)分钟"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if remainingMinutes == 0 {
            return "\(hours)小时"
        }
        return "\(hours)小时\(remainingMinutes)分钟"
    }
}

struct ApplicationTarget: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    let processIdentifier: Int32
}

struct SchedulePlan: Equatable, Sendable {
    let action: ScheduledAction
    let targets: [ApplicationTarget]
    let fireDate: Date

    func validationMessage(relativeTo now: Date) -> String? {
        if fireDate <= now {
            return "执行时间必须晚于当前时间"
        }
        if action == .quitApplications && targets.isEmpty {
            return "请至少选择一个要关闭的应用"
        }
        return nil
    }

    func remainingTime(relativeTo now: Date) -> TimeInterval {
        max(0, fireDate.timeIntervalSince(now))
    }
}

enum ScheduleDateCalculator {
    static func date(afterMinutes minutes: Int, now: Date) -> Date {
        now.addingTimeInterval(TimeInterval(minutes * 60))
    }
}
