import Foundation

protocol ClipboardStore {
    func loadEntries() -> [ClipboardEntry]
    func saveEntries(_ entries: [ClipboardEntry])
    func upsertTextEntry(_ text: String, sourceApp: String?, ignoreDuplicateConsecutive: Bool, maxHistorySize: Int)
    func setPinned(_ isPinned: Bool, id: UUID)
    func delete(id: UUID)
    func prune(maxHistorySize: Int)
    func allEntries() -> [ClipboardEntry]
}

final class JSONClipboardStore: ClipboardStore {
    private let queue = DispatchQueue(label: "clipboard.store.queue")
    private let fileURL: URL
    private var entries: [ClipboardEntry] = []

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = appSupport.appendingPathComponent("ClipboardHistory", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            self.fileURL = dir.appendingPathComponent("entries.json")
        }
        self.entries = loadEntries()
    }

    func loadEntries() -> [ClipboardEntry] {
        queue.sync {
            guard let data = try? Data(contentsOf: fileURL),
                  let decoded = try? JSONDecoder().decode([ClipboardEntry].self, from: data) else {
                return []
            }
            entries = decoded
            return decoded
        }
    }

    func saveEntries(_ entries: [ClipboardEntry]) {
        queue.sync {
            self.entries = entries
            guard let data = try? JSONEncoder().encode(entries) else { return }
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func upsertTextEntry(_ text: String, sourceApp: String?, ignoreDuplicateConsecutive: Bool, maxHistorySize: Int) {
        queue.sync {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            if ignoreDuplicateConsecutive, let first = entries.first, first.rawPayloadRef == trimmed {
                return
            }

            entries.removeAll { !$0.isPinned && $0.rawPayloadRef == trimmed }

            let preview = String(trimmed.prefix(240))
            let entry = ClipboardEntry(
                kind: .text,
                plainTextPreview: preview,
                rawPayloadRef: trimmed,
                isPinned: false,
                sourceApp: sourceApp
            )
            entries.insert(entry, at: 0)
            entries = Self.prunedEntries(entries, maxHistorySize: maxHistorySize)
            persistLocked()
        }
    }

    func setPinned(_ isPinned: Bool, id: UUID) {
        queue.sync {
            guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
            entries[index].isPinned = isPinned
            persistLocked()
        }
    }

    func delete(id: UUID) {
        queue.sync {
            entries.removeAll(where: { $0.id == id })
            persistLocked()
        }
    }

    func prune(maxHistorySize: Int) {
        queue.sync {
            entries = Self.prunedEntries(entries, maxHistorySize: maxHistorySize)
            persistLocked()
        }
    }

    func allEntries() -> [ClipboardEntry] {
        queue.sync { entries }
    }

    private func persistLocked() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func prunedEntries(_ entries: [ClipboardEntry], maxHistorySize: Int) -> [ClipboardEntry] {
        let pinned = entries.filter(\.isPinned)
        let unpinned = entries.filter { !$0.isPinned }
        let unpinnedLimit = max(0, maxHistorySize - pinned.count)
        return pinned + Array(unpinned.prefix(unpinnedLimit))
    }
}
