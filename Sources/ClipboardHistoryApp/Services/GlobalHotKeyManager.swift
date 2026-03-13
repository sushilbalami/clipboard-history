import Carbon
import Foundation

protocol HotKeyManaging: AnyObject {
    var onPressed: (() -> Void)? { get set }
    func register(_ shortcut: ShortcutConfiguration)
    func unregister()
}

final class GlobalHotKeyManager: HotKeyManaging {
    var onPressed: (() -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x43424853), id: 1)

    deinit {
        unregister()
    }

    func register(_ shortcut: ShortcutConfiguration) {
        unregister()
        guard shortcut.isValid else { return }

        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard status == noErr else { return }
        installHandlerIfNeeded()
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    private func installHandlerIfNeeded() {
        guard eventHandler == nil else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, _, userData in
            guard let userData else { return noErr }
            let manager = Unmanaged<GlobalHotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.onPressed?()
            return noErr
        }
        let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventType, userData, &eventHandler)
    }
}
