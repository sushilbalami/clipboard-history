import Foundation
import ServiceManagement

@MainActor
final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()

    func updateEnabled(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Best effort: registration can fail in development contexts.
            }
        }
    }
}
