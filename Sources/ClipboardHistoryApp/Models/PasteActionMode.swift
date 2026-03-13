import Foundation

enum PasteActionMode: String, Codable, CaseIterable, Identifiable {
    case paste
    case copy

    var id: String { rawValue }
}
