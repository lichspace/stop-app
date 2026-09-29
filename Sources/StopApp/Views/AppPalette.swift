import AppKit
import SwiftUI

enum AppPalette {
    static let accent = adaptive(
        light: NSColor(calibratedRed: 0.29, green: 0.37, blue: 0.86, alpha: 1),
        dark: NSColor(calibratedRed: 0.59, green: 0.64, blue: 1.00, alpha: 1)
    )

    static let sidebar = adaptive(
        light: NSColor(calibratedRed: 0.95, green: 0.96, blue: 0.985, alpha: 1),
        dark: NSColor(calibratedRed: 0.13, green: 0.14, blue: 0.18, alpha: 1)
    )

    static let canvas = adaptive(
        light: NSColor(calibratedRed: 0.985, green: 0.989, blue: 0.998, alpha: 1),
        dark: NSColor(calibratedRed: 0.105, green: 0.11, blue: 0.145, alpha: 1)
    )

    static let hover = adaptive(
        light: NSColor(calibratedRed: 0.925, green: 0.94, blue: 0.985, alpha: 1),
        dark: NSColor(calibratedRed: 0.19, green: 0.205, blue: 0.27, alpha: 1)
    )

    static let selection = adaptive(
        light: NSColor(calibratedRed: 0.89, green: 0.91, blue: 1.00, alpha: 1),
        dark: NSColor(calibratedRed: 0.23, green: 0.255, blue: 0.39, alpha: 1)
    )

    private static func adaptive(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        })
    }
}
