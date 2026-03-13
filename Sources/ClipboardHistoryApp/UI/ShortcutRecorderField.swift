import AppKit
import Carbon
import SwiftUI

struct ShortcutRecorderField: NSViewRepresentable {
    @Binding var shortcut: ShortcutConfiguration
    let onChange: (ShortcutConfiguration) -> Void

    func makeNSView(context: Context) -> ShortcutRecorderNSView {
        let view = ShortcutRecorderNSView()
        view.onShortcutCaptured = { captured in
            shortcut = captured
            onChange(captured)
        }
        view.shortcut = shortcut
        return view
    }

    func updateNSView(_ nsView: ShortcutRecorderNSView, context: Context) {
        nsView.shortcut = shortcut
    }
}

final class ShortcutRecorderNSView: NSView {
    var onShortcutCaptured: ((ShortcutConfiguration) -> Void)?
    var shortcut: ShortcutConfiguration = .default {
        didSet { needsDisplay = true }
    }

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.controlBackgroundColor.withAlphaComponent(0.7).setFill()
        let background = NSBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8)
        background.fill()

        NSColor.separatorColor.withAlphaComponent(0.6).setStroke()
        background.lineWidth = 1
        background.stroke()

        let text = window?.firstResponder === self ? "Press keys..." : shortcut.displayName
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor.labelColor
        ]
        let size = text.size(withAttributes: attrs)
        let point = CGPoint(x: 10, y: (bounds.height - size.height) / 2)
        text.draw(at: point, withAttributes: attrs)
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        needsDisplay = true
    }

    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return true
    }

    override func keyDown(with event: NSEvent) {
        let modifiers = carbonModifiers(from: event.modifierFlags)
        guard modifiers != 0 else { return }
        let keyCode = UInt32(event.keyCode)
        let captured = ShortcutConfiguration(keyCode: keyCode, modifiers: modifiers)
        shortcut = captured
        onShortcutCaptured?(captured)
    }

    private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var value: UInt32 = 0
        if flags.contains(.command) { value |= UInt32(cmdKey) }
        if flags.contains(.option) { value |= UInt32(optionKey) }
        if flags.contains(.shift) { value |= UInt32(shiftKey) }
        if flags.contains(.control) { value |= UInt32(controlKey) }
        return value
    }
}
