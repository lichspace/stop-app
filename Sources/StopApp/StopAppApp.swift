import SwiftUI

@main
struct StopAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)

        Settings {
            SettingsView()
        }
    }
}

private struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("定时关")
                .font(.title2.bold())
            Text("计时任务仅在“定时关”保持运行时有效。系统睡眠后唤醒，已到期的任务会立即执行。")
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 420)
    }
}
