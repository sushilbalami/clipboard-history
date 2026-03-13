import Foundation

@MainActor
final class AppSettings: ObservableObject {
    @Published var shortcut: ShortcutConfiguration {
        didSet { save() }
    }
    @Published var defaultAction: PasteActionMode {
        didSet { save() }
    }
    @Published var maxHistorySize: Int {
        didSet { save() }
    }
    @Published var ignoreDuplicateConsecutiveItems: Bool {
        didSet { save() }
    }
    @Published var launchAtLogin: Bool {
        didSet { save() }
    }

    private let defaults = UserDefaults.standard

    init() {
        if let data = defaults.data(forKey: "shortcut"),
           let shortcut = try? JSONDecoder().decode(ShortcutConfiguration.self, from: data) {
            self.shortcut = shortcut
        } else {
            self.shortcut = .default
        }

        self.defaultAction = PasteActionMode(rawValue: defaults.string(forKey: "defaultAction") ?? "") ?? .paste
        let savedMax = defaults.integer(forKey: "maxHistorySize")
        self.maxHistorySize = savedMax == 0 ? 120 : max(20, min(500, savedMax))
        self.ignoreDuplicateConsecutiveItems = defaults.object(forKey: "ignoreDuplicateConsecutiveItems") as? Bool ?? true
        self.launchAtLogin = defaults.object(forKey: "launchAtLogin") as? Bool ?? true
    }

    private func save() {
        if let data = try? JSONEncoder().encode(shortcut) {
            defaults.set(data, forKey: "shortcut")
        }
        defaults.set(defaultAction.rawValue, forKey: "defaultAction")
        defaults.set(max(20, min(500, maxHistorySize)), forKey: "maxHistorySize")
        defaults.set(ignoreDuplicateConsecutiveItems, forKey: "ignoreDuplicateConsecutiveItems")
        defaults.set(launchAtLogin, forKey: "launchAtLogin")
    }
}
