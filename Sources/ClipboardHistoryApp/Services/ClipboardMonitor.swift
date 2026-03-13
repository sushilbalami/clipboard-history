import AppKit
import Foundation

@MainActor
protocol ClipboardMonitor {
    func start()
    func stop()
}

@MainActor
final class PasteboardMonitor: ClipboardMonitor {
    private let pasteboard: NSPasteboard
    private let onTextCapture: (String, String?) -> Void
    private var timer: Timer?
    private var lastChangeCount: Int

    init(
        pasteboard: NSPasteboard = .general,
        onTextCapture: @escaping (String, String?) -> Void
    ) {
        self.pasteboard = pasteboard
        self.onTextCapture = onTextCapture
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.tick()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        let sourceApp = NSWorkspace.shared.frontmostApplication?.localizedName
        onTextCapture(text, sourceApp)
    }
}
