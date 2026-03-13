import AppKit
import Carbon
import Foundation

struct ShortcutConfiguration: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    static let `default` = ShortcutConfiguration(
        keyCode: UInt32(kVK_ANSI_V),
        modifiers: UInt32(cmdKey | shiftKey)
    )

    var isValid: Bool { keyCode > 0 }

    var displayName: String {
        let key = Self.keyDisplayName(for: keyCode)
        return "\(modifierDisplayName)\(key)"
    }

    var modifierDisplayName: String {
        var symbols = ""
        if modifiers & UInt32(cmdKey) != 0 { symbols += "⌘" }
        if modifiers & UInt32(optionKey) != 0 { symbols += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { symbols += "⇧" }
        if modifiers & UInt32(controlKey) != 0 { symbols += "⌃" }
        return symbols
    }

    static func fromCharacters(
        key: String,
        command: Bool,
        option: Bool,
        shift: Bool,
        control: Bool
    ) -> ShortcutConfiguration? {
        guard let first = key.lowercased().first, let keyCode = keyCodeMap[first] else {
            return nil
        }
        var modifiers: UInt32 = 0
        if command { modifiers |= UInt32(cmdKey) }
        if option { modifiers |= UInt32(optionKey) }
        if shift { modifiers |= UInt32(shiftKey) }
        if control { modifiers |= UInt32(controlKey) }
        return ShortcutConfiguration(keyCode: keyCode, modifiers: modifiers)
    }

    static func keyDisplayName(for keyCode: UInt32) -> String {
        if let letter = keyCodeMap.first(where: { $0.value == keyCode })?.key {
            return String(letter).uppercased()
        }
        return "?"
    }

    private static let keyCodeMap: [Character: UInt32] = [
        "a": UInt32(kVK_ANSI_A), "b": UInt32(kVK_ANSI_B), "c": UInt32(kVK_ANSI_C), "d": UInt32(kVK_ANSI_D),
        "e": UInt32(kVK_ANSI_E), "f": UInt32(kVK_ANSI_F), "g": UInt32(kVK_ANSI_G), "h": UInt32(kVK_ANSI_H),
        "i": UInt32(kVK_ANSI_I), "j": UInt32(kVK_ANSI_J), "k": UInt32(kVK_ANSI_K), "l": UInt32(kVK_ANSI_L),
        "m": UInt32(kVK_ANSI_M), "n": UInt32(kVK_ANSI_N), "o": UInt32(kVK_ANSI_O), "p": UInt32(kVK_ANSI_P),
        "q": UInt32(kVK_ANSI_Q), "r": UInt32(kVK_ANSI_R), "s": UInt32(kVK_ANSI_S), "t": UInt32(kVK_ANSI_T),
        "u": UInt32(kVK_ANSI_U), "v": UInt32(kVK_ANSI_V), "w": UInt32(kVK_ANSI_W), "x": UInt32(kVK_ANSI_X),
        "y": UInt32(kVK_ANSI_Y), "z": UInt32(kVK_ANSI_Z),
        "0": UInt32(kVK_ANSI_0), "1": UInt32(kVK_ANSI_1), "2": UInt32(kVK_ANSI_2), "3": UInt32(kVK_ANSI_3),
        "4": UInt32(kVK_ANSI_4), "5": UInt32(kVK_ANSI_5), "6": UInt32(kVK_ANSI_6), "7": UInt32(kVK_ANSI_7),
        "8": UInt32(kVK_ANSI_8), "9": UInt32(kVK_ANSI_9)
    ]
}
