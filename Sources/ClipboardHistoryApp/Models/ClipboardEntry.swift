import Foundation

enum ClipboardEntryKind: String, Codable {
    case text
    case unsupported
}

struct ClipboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let kind: ClipboardEntryKind
    let plainTextPreview: String
    let rawPayloadRef: String
    var isPinned: Bool
    let sourceApp: String?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        kind: ClipboardEntryKind = .text,
        plainTextPreview: String,
        rawPayloadRef: String,
        isPinned: Bool = false,
        sourceApp: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kind = kind
        self.plainTextPreview = plainTextPreview
        self.rawPayloadRef = rawPayloadRef
        self.isPinned = isPinned
        self.sourceApp = sourceApp
    }
}
