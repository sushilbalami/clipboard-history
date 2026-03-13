import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    private let window: NSWindow

    init(settings: AppSettings, onShortcutChange: @escaping (ShortcutConfiguration) -> Void) {
        let rootView = SettingsView(settings: settings, onShortcutChange: onShortcutChange)
        let hosting = NSHostingView(rootView: rootView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 360),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Clipboard History Settings"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isReleasedWhenClosed = false
        window.center()
        window.level = .floating
        window.contentView = hosting
        self.window = window
    }

    func show() {
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
