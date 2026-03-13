import AppKit
import SwiftUI

@MainActor
final class OnboardingWindowController {
    private let window: NSWindow

    init(settings: AppSettings, onOpenSettings: @escaping () -> Void, onComplete: @escaping () -> Void) {
        let view = OnboardingView(settings: settings, onOpenSettings: onOpenSettings, onComplete: onComplete)
        let hosting = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 360),
            styleMask: [.titled, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Clipboard History Setup"
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
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

    func close() {
        window.orderOut(nil)
    }
}
