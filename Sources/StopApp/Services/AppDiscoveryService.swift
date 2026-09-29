import AppKit

struct RunningApplicationItem: Identifiable, Hashable {
    let application: NSRunningApplication
    let id: String
    let name: String
    let bundleIdentifier: String?
    let processIdentifier: Int32
    let icon: NSImage

    init(application: NSRunningApplication) {
        self.application = application
        bundleIdentifier = application.bundleIdentifier
        processIdentifier = application.processIdentifier
        name = application.localizedName ?? "未命名应用"
        id = application.bundleIdentifier ?? "pid:\(application.processIdentifier)"
        icon = application.icon ?? NSImage(systemSymbolName: "app", accessibilityDescription: nil) ?? NSImage()
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.processIdentifier == rhs.processIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(processIdentifier)
    }

    var target: ApplicationTarget {
        ApplicationTarget(
            id: id,
            name: name,
            bundleIdentifier: bundleIdentifier,
            processIdentifier: processIdentifier
        )
    }
}

@MainActor
final class AppDiscoveryService {
    func runningApplications() -> [RunningApplicationItem] {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        var seen = Set<String>()

        return NSWorkspace.shared.runningApplications
            .filter { application in
                application.activationPolicy == .regular
                    && !application.isTerminated
                    && application.processIdentifier != currentPID
            }
            .map(RunningApplicationItem.init)
            .filter { seen.insert($0.id).inserted }
            .sorted { lhs, rhs in
                lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
    }
}
