import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var entries: [ClipboardEntry] = []
    @Published var searchQuery: String = ""
    @Published var isCapturePaused: Bool = false
    @Published var lastActionMessage: String?

    let settings: AppSettings

    private let store: ClipboardStore
    private var cancellables: Set<AnyCancellable> = []

    init(store: ClipboardStore, settings: AppSettings) {
        self.store = store
        self.settings = settings
        self.entries = store.loadEntries()
        settings.$maxHistorySize
            .sink { [weak self] maxSize in
                guard let self else { return }
                self.store.prune(maxHistorySize: maxSize)
                self.reload()
            }
            .store(in: &cancellables)
    }

    var filteredEntries: [ClipboardEntry] {
        guard !searchQuery.isEmpty else { return entries }
        return entries.filter { entry in
            entry.plainTextPreview.localizedCaseInsensitiveContains(searchQuery) ||
            entry.rawPayloadRef.localizedCaseInsensitiveContains(searchQuery) ||
            (entry.sourceApp?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }

    func capture(_ text: String, sourceApp: String?) {
        guard !isCapturePaused else { return }
        store.upsertTextEntry(
            text,
            sourceApp: sourceApp,
            ignoreDuplicateConsecutive: settings.ignoreDuplicateConsecutiveItems,
            maxHistorySize: settings.maxHistorySize
        )
        reload()
    }

    func togglePinned(_ entry: ClipboardEntry) {
        store.setPinned(!entry.isPinned, id: entry.id)
        reload()
    }

    func delete(_ entry: ClipboardEntry) {
        store.delete(id: entry.id)
        reload()
    }

    func reload() {
        entries = store.allEntries()
    }
}
