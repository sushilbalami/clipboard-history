import Foundation
import Testing
@testable import ClipboardHistoryApp

struct ClipboardStoreTests {
    @Test
    func deduplicatesConsecutiveItems() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let store = JSONClipboardStore(fileURL: url)

        store.upsertTextEntry("hello", sourceApp: "Notes", ignoreDuplicateConsecutive: true, maxHistorySize: 20)
        store.upsertTextEntry("hello", sourceApp: "Notes", ignoreDuplicateConsecutive: true, maxHistorySize: 20)

        #expect(store.allEntries().count == 1)
    }

    @Test
    func keepsPinnedEntriesDuringPrune() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let store = JSONClipboardStore(fileURL: url)
        store.upsertTextEntry("a", sourceApp: nil, ignoreDuplicateConsecutive: false, maxHistorySize: 20)
        store.upsertTextEntry("b", sourceApp: nil, ignoreDuplicateConsecutive: false, maxHistorySize: 20)
        store.upsertTextEntry("c", sourceApp: nil, ignoreDuplicateConsecutive: false, maxHistorySize: 20)
        guard let pinnedID = store.allEntries().last?.id else {
            Issue.record("Missing entry to pin")
            return
        }
        store.setPinned(true, id: pinnedID)
        store.prune(maxHistorySize: 2)

        let entries = store.allEntries()
        #expect(entries.count == 2)
        #expect(entries.contains(where: { $0.id == pinnedID && $0.isPinned }))
    }
}
