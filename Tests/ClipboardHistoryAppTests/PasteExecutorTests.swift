import AppKit
import Testing
@testable import ClipboardHistoryApp

private struct DeniedPermissionChecker: PermissionChecking {
    func hasAccessibilityPermission() -> Bool { false }
}

private struct AllowPermissionChecker: PermissionChecking {
    func hasAccessibilityPermission() -> Bool { true }
}

private final class SpyPoster: PasteEventPosting {
    private(set) var didPost = false
    func postCommandV() { didPost = true }
}

struct PasteExecutorTests {
    @Test
    @MainActor
    func fallsBackToCopyWhenPermissionDenied() {
        let poster = SpyPoster()
        let executor = SystemPasteExecutor(
            permissionChecker: DeniedPermissionChecker(),
            poster: poster,
            pasteboard: NSPasteboard(name: .init("test-pb-\(UUID().uuidString)"))
        )
        let entry = ClipboardEntry(plainTextPreview: "x", rawPayloadRef: "x")
        let result = executor.execute(entry: entry, requested: .paste, previousApp: nil)
        #expect(result == .copy)
        #expect(poster.didPost == false)
    }

    @Test
    @MainActor
    func staysInPasteModeWhenPermissionGranted() {
        let poster = SpyPoster()
        let executor = SystemPasteExecutor(
            permissionChecker: AllowPermissionChecker(),
            poster: poster,
            pasteboard: NSPasteboard(name: .init("test-pb-\(UUID().uuidString)"))
        )
        let entry = ClipboardEntry(plainTextPreview: "x", rawPayloadRef: "x")
        let result = executor.execute(entry: entry, requested: .paste, previousApp: nil)
        #expect(result == .paste)
    }
}
