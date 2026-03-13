import Carbon
import Testing
@testable import ClipboardHistoryApp

struct ShortcutConfigurationTests {
    @Test
    func canEncodeAndDecodeShortcut() throws {
        let shortcut = ShortcutConfiguration(
            keyCode: UInt32(kVK_ANSI_V),
            modifiers: UInt32(cmdKey | shiftKey)
        )
        let data = try JSONEncoder().encode(shortcut)
        let decoded = try JSONDecoder().decode(ShortcutConfiguration.self, from: data)
        #expect(decoded == shortcut)
        #expect(decoded.isValid)
    }
}
