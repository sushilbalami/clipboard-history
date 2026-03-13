import Foundation
import Testing
@testable import ClipboardHistoryApp

@MainActor
struct HistoryViewModelTests {
    @Test
    func searchFiltersEntries() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let store = JSONClipboardStore(fileURL: url)
        let settings = AppSettings()
        let vm = HistoryViewModel(store: store, settings: settings)

        vm.capture("apple", sourceApp: "Notes")
        vm.capture("banana", sourceApp: "Safari")
        vm.searchQuery = "banana"

        #expect(vm.filteredEntries.count == 1)
        #expect(vm.filteredEntries.first?.rawPayloadRef == "banana")
    }
}
