import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var model = SchedulerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            HStack(spacing: 0) {
                sidebar
                Divider()
                workspace
            }
        }
        .frame(minWidth: 760, minHeight: 600)
        .background(AppPalette.canvas)
        .tint(AppPalette.accent)
        .animation(.easeInOut(duration: 0.18), value: model.action)
        .animation(.easeInOut(duration: 0.18), value: model.durationSelectionMinutes)
        .animation(.easeInOut(duration: 0.18), value: model.scheduledPlan)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(nsImage: appIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 1) {
                Text("定时关")
                    .font(.system(size: 19, weight: .semibold))
                Text("定时关闭应用或电脑")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let plan = model.scheduledPlan {
                HStack(spacing: 7) {
                    Circle()
                        .fill(.green)
                        .frame(width: 7, height: 7)
                    Text(plan.action.title)
                    Text(model.remainingText)
                        .font(.system(.callout, design: .monospaced, weight: .semibold))
                        .monospacedDigit()
                }
                .font(.callout)
                .padding(.horizontal, 12)
                .frame(height: 30)
                .background(AppPalette.selection, in: Capsule())
            } else {
                Text("任务期间请保持应用运行")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 70)
        .background(AppPalette.sidebar)
    }

    private var appIcon: NSImage {
        if let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        return NSApplication.shared.applicationIconImage
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            SidebarLabel(title: "执行操作", systemImage: "bolt.fill")

            Picker("执行操作", selection: $model.action) {
                Text("关闭应用").tag(ScheduledAction.quitApplications)
                Text("关闭电脑").tag(ScheduledAction.shutDown)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .disabled(model.scheduledPlan != nil || model.isExecuting)
            .padding(.top, 10)

            Divider()
                .padding(.vertical, 20)

            SidebarLabel(title: "倒计时", systemImage: "timer")

            Picker("倒计时时长", selection: $model.durationSelectionMinutes) {
                ForEach(DurationOption.menuOptions) { option in
                    Text(option.title).tag(option.minutes)
                }
                Divider()
                Text("手动输入…").tag(0)
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .disabled(model.scheduledPlan != nil || model.isExecuting)
            .padding(.top, 10)

            if model.durationSelectionMinutes == 0 {
                HStack(spacing: 8) {
                    TextField("分钟数", text: $model.manualMinutesText)
                        .textFieldStyle(.roundedBorder)
                    Text("分钟")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Text(model.durationSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            if model.action == .shutDown {
                Label("关机前请保存未完成的工作", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 16)
            }

            Spacer(minLength: 16)

            if let plan = model.scheduledPlan {
                activeSchedule(plan)
                    .padding(.bottom, 12)
            }

            if let statusMessage = model.statusMessage {
                Label(
                    statusMessage,
                    systemImage: model.statusIsError ? "exclamationmark.circle.fill" : "checkmark.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(model.statusIsError ? Color.red : Color.green)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 10)
            } else if let validationMessage = model.validationMessage, model.scheduledPlan == nil {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
            }

            Button {
                model.schedule()
            } label: {
                HStack(spacing: 7) {
                    if model.isExecuting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text(model.isExecuting ? "正在执行…" : model.primaryButtonTitle)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!model.canSchedule)
        }
        .padding(20)
        .frame(width: 260)
        .background(AppPalette.sidebar)
    }

    @ViewBuilder
    private var workspace: some View {
        if model.action == .quitApplications {
            applicationWorkspace
                .transition(.opacity)
        } else {
            shutdownWorkspace
                .transition(.opacity)
        }
    }

    private var applicationWorkspace: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("正在运行的应用")
                        .font(.title3.weight(.semibold))
                    Text("已找到 \(model.runningApplications.count) 个应用，已选择 \(model.selectedApplications.count) 个")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    model.refreshApplications()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help("刷新应用列表")
                .disabled(model.scheduledPlan != nil || model.isExecuting)
            }
            .padding(.horizontal, 22)
            .padding(.top, 19)
            .padding(.bottom, 13)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索名称或 Bundle ID", text: $model.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(AppPalette.sidebar, in: RoundedRectangle(cornerRadius: 7))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.55))
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 14)
            .disabled(model.scheduledPlan != nil || model.isExecuting)

            Divider()

            if model.filteredApplications.isEmpty {
                VStack(spacing: 9) {
                    Image(systemName: "app.dashed")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(.tertiary)
                    Text(model.searchText.isEmpty ? "暂无可选应用" : "没有匹配的应用")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(model.filteredApplications) { application in
                            ApplicationRow(
                                application: application,
                                isSelected: model.selectedApplicationIDs.contains(application.id)
                            ) {
                                model.toggleSelection(for: application)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .disabled(model.scheduledPlan != nil || model.isExecuting)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppPalette.canvas)
    }

    private var shutdownWorkspace: some View {
        VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.10))
                Image(systemName: "power")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundStyle(.orange)
            }
            .frame(width: 94, height: 94)

            VStack(spacing: 7) {
                Text("定时关闭电脑")
                    .font(.title2.weight(.semibold))
                Text(model.durationSummary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("任务到期后会向 macOS 发送关机请求。首次使用时，\n系统可能要求允许“定时关”控制系统事件。")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 5)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func activeSchedule(_ plan: SchedulePlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label("任务进行中", systemImage: plan.action.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
                Spacer()
                Text(model.remainingText)
                    .font(.system(.callout, design: .monospaced, weight: .semibold))
                    .monospacedDigit()
            }

            Text(plan.fireDate, format: .dateTime.month().day().hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("取消任务") {
                model.cancelSchedule()
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(12)
        .background(Color.green.opacity(0.085), in: RoundedRectangle(cornerRadius: 9))
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.green.opacity(0.18))
        }
    }
}

private struct SidebarLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

private struct ApplicationRow: View {
    let application: RunningApplicationItem
    let isSelected: Bool
    let onToggle: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 11) {
                Image(nsImage: application.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 1) {
                    Text(application.name)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                    if let bundleIdentifier = application.bundleIdentifier {
                        Text(bundleIdentifier)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.4))
            }
            .padding(.horizontal, 10)
            .frame(height: 48)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.10)) {
                isHovered = hovering
            }
        }
        .accessibilityValue(isSelected ? "已选择" : "未选择")
    }

    private var rowBackground: Color {
        if isSelected {
            return isHovered ? AppPalette.selection.opacity(0.82) : AppPalette.selection
        }
        return isHovered ? AppPalette.hover : Color.clear
    }
}
