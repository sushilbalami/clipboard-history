import ApplicationServices
import AppKit
import Foundation

protocol PermissionChecking {
    func hasAccessibilityPermission() -> Bool
}

protocol PasteEventPosting {
    func postCommandV()
}

struct AccessibilityPermissionChecker: PermissionChecking {
    func hasAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }
}

struct CGEventPastePoster: PasteEventPosting {
    func postCommandV() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}

@MainActor
protocol PasteExecutor {
    func execute(
        entry: ClipboardEntry,
        requested: PasteActionMode,
        previousApp: NSRunningApplication?
    ) -> PasteActionMode
}

@MainActor
final class SystemPasteExecutor: PasteExecutor {
    private let permissionChecker: PermissionChecking
    private let poster: PasteEventPosting
    private let pasteboard: NSPasteboard

    init(
        permissionChecker: PermissionChecking = AccessibilityPermissionChecker(),
        poster: PasteEventPosting = CGEventPastePoster(),
        pasteboard: NSPasteboard = .general
    ) {
        self.permissionChecker = permissionChecker
        self.poster = poster
        self.pasteboard = pasteboard
    }

    func execute(
        entry: ClipboardEntry,
        requested: PasteActionMode,
        previousApp: NSRunningApplication?
    ) -> PasteActionMode {
        pasteboard.clearContents()
        pasteboard.setString(entry.rawPayloadRef, forType: .string)

        let resolved = resolvedMode(requested: requested)
        guard resolved == .paste else { return .copy }

        previousApp?.activate()
        let poster = self.poster
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(90))
            poster.postCommandV()
        }
        return .paste
    }

    func resolvedMode(requested: PasteActionMode) -> PasteActionMode {
        guard requested == .paste else { return .copy }
        return permissionChecker.hasAccessibilityPermission() ? .paste : .copy
    }
}
