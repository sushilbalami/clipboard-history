import AppKit
import SwiftUI

private final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
final class HistoryPanelController: NSObject, NSWindowDelegate {
    private let panel: FloatingPanel
    private let viewModel: HistoryViewModel
    private let pasteExecutor: PasteExecutor
    private var selectedID: ClipboardEntry.ID?
    private var previousApp: NSRunningApplication?
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?

    init(viewModel: HistoryViewModel, pasteExecutor: PasteExecutor) {
        self.viewModel = viewModel
        self.pasteExecutor = pasteExecutor
        self.panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 520),
            styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        super.init()
        configurePanel()
    }

    func toggle() {
        panel.isVisible ? hide() : show()
    }

    func show() {
        previousApp = NSWorkspace.shared.frontmostApplication
        viewModel.reload()
        placeNearCursor()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        installDismissMonitorsIfNeeded()
    }

    func hide() {
        panel.orderOut(nil)
        viewModel.searchQuery = ""
        selectedID = nil
        removeDismissMonitors()
    }

    private func configurePanel() {
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isMovable = true
        panel.isMovableByWindowBackground = true

        let root = HistoryPanelView(
            viewModel: viewModel,
            selectedID: Binding(
                get: { self.selectedID },
                set: { self.selectedID = $0 }
            ),
            onMinimize: { [weak self] in
                self?.panel.miniaturize(nil)
            },
            onClose: { [weak self] in
                self?.hide()
            },
            onDismiss: { [weak self] in self?.hide() },
            onPerform: { [weak self] entry, mode in
                self?.perform(entry: entry, mode: mode)
            }
        )
        panel.contentView = NSHostingView(rootView: root)
    }

    private func perform(entry: ClipboardEntry, mode: PasteActionMode) {
        let resolved = pasteExecutor.execute(entry: entry, requested: mode, previousApp: previousApp)
        if mode == .paste, resolved == .copy {
            viewModel.lastActionMessage = "Accessibility permission missing: copied instead."
        } else {
            viewModel.lastActionMessage = resolved == .paste ? "Pasted." : "Copied."
        }
        hide()
    }

    private func placeNearCursor() {
        let mousePoint = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { NSMouseInRect(mousePoint, $0.frame, false) }) ?? NSScreen.main
        guard let screen else { return }
        let frame = screen.visibleFrame
        let width: CGFloat = 620
        let height: CGFloat = 520
        let padding: CGFloat = 16

        var x = mousePoint.x - (width / 2)
        x = max(frame.minX + padding, min(x, frame.maxX - width - padding))

        var y = mousePoint.y - height - 18
        if y < frame.minY + padding {
            y = min(frame.maxY - height - padding, mousePoint.y + 18)
        }
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    func windowDidResignKey(_ notification: Notification) {
        // Outside click dismissal is handled by event monitors.
    }

    private func installDismissMonitorsIfNeeded() {
        guard localEventMonitor == nil, globalEventMonitor == nil else { return }

        let mouseEvents: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown, .otherMouseDown]
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: mouseEvents) { [weak self] event in
            self?.dismissIfClickOutside(event)
            return event
        }
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: mouseEvents) { [weak self] event in
            self?.dismissIfClickOutside(event)
        }
    }

    private func removeDismissMonitors() {
        if let localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
        if let globalEventMonitor {
            NSEvent.removeMonitor(globalEventMonitor)
            self.globalEventMonitor = nil
        }
    }

    private func dismissIfClickOutside(_ event: NSEvent) {
        guard panel.isVisible else { return }
        let clickLocation = event.locationInWindow
        let pointInScreen: NSPoint

        if event.window == nil {
            pointInScreen = clickLocation
        } else {
            pointInScreen = event.window?.convertPoint(toScreen: clickLocation) ?? clickLocation
        }

        if !panel.frame.contains(pointInScreen) {
            hide()
        }
    }
}
