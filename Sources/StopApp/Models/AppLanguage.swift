import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese = "zh-Hans"
    case english = "en"

    static let storageKey = "appLanguage"

    static var defaultLanguage: AppLanguage {
        Locale.preferredLanguages.first?.hasPrefix("zh") == true ? .chinese : .english
    }

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chinese: "简体中文"
        case .english: "English"
        }
    }

    func text(_ chinese: String) -> String {
        guard self == .english else { return chinese }
        return Self.englishTranslations[chinese] ?? chinese
    }

    func readableDuration(minutes: Int) -> String {
        guard self == .english else {
            return DurationTextFormatter.readable(minutes: minutes)
        }

        guard minutes >= 60 else {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        let hourText = "\(hours) \(hours == 1 ? "hour" : "hours")"
        guard remainingMinutes > 0 else { return hourText }
        return "\(hourText) \(remainingMinutes) \(remainingMinutes == 1 ? "minute" : "minutes")"
    }

    private static let englishTranslations: [String: String] = [
        "定时关": "StopApp",
        "定时关闭应用或电脑": "Schedule apps to quit or shut down",
        "任务期间请保持应用运行": "Keep StopApp running while a timer is active",
        "语言": "Language",
        "执行操作": "Action",
        "关闭应用": "Quit apps",
        "关闭电脑": "Shut down Mac",
        "倒计时": "Countdown",
        "倒计时时长": "Duration",
        "手动输入…": "Enter manually…",
        "分钟数": "Minutes",
        "分钟": "min",
        "关机前请保存未完成的工作": "Save your work before shutting down",
        "正在执行…": "Working…",
        "开始计时": "Start countdown",
        "安排关机": "Schedule shutdown",
        "正在运行的应用": "Running apps",
        "已找到 %d 个应用，已选择 %d 个": "%d apps found, %d selected",
        "刷新应用列表": "Refresh app list",
        "搜索名称或 Bundle ID": "Search by name or bundle ID",
        "暂无可选应用": "No apps available",
        "没有匹配的应用": "No matching apps",
        "定时关闭电脑": "Schedule Mac shutdown",
        "任务到期后会向 macOS 发送关机请求。首次使用时，\n系统可能要求允许“定时关”控制系统事件。": "When the timer ends, StopApp asks macOS to shut down. The first time,\nmacOS may ask you to allow StopApp to control System Events.",
        "任务进行中": "Timer running",
        "取消任务": "Cancel timer",
        "已选择": "Selected",
        "未选择": "Not selected",
        "等待输入时长": "Enter a duration",
        "执行时间必须晚于当前时间": "The scheduled time must be in the future",
        "请至少选择一个要关闭的应用": "Select at least one app to quit",
        "请输入有效的分钟数": "Enter a valid number of minutes",
        "分钟数必须大于 0": "Minutes must be greater than 0",
        "最长可设置 7 天（10080 分钟）": "The maximum duration is 7 days (10,080 minutes)",
        "已取消定时任务": "Timer canceled",
        "所选应用已不在运行": "The selected apps are no longer running",
        "无法关闭所选应用": "Could not quit the selected apps",
        "系统拒绝了关机请求": "macOS denied the shutdown request",
        "已向系统发送关机请求": "Shutdown request sent to macOS",
        "计时任务仅在“定时关”保持运行时有效。系统睡眠后唤醒，已到期的任务会立即执行。": "Timers run only while StopApp is open. If your Mac sleeps, an overdue action runs when it wakes.",
        "界面语言": "App language"
    ]
}
