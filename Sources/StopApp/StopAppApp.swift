import SwiftUI

@main
struct StopAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 680)
        }
        .windowStyle(.hiddenTitleBar)

        Settings {
            SettingsView()
        }
    }
}

private struct SettingsView: View {
    @AppStorage(AppLanguage.storageKey) private var languageIdentifier = AppLanguage.defaultLanguage.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: languageIdentifier) ?? AppLanguage.defaultLanguage
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(language.text("定时关"))
                .font(.title2.bold())
            Text(language.text("计时任务仅在“定时关”保持运行时有效。系统睡眠后唤醒，已到期的任务会立即执行。"))
                .foregroundStyle(.secondary)

            Picker(language.text("界面语言"), selection: $languageIdentifier) {
                ForEach(AppLanguage.allCases) { option in
                    Text(option.displayName).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(24)
        .frame(width: 460)
        .environment(\.locale, Locale(identifier: language.rawValue))
    }
}
