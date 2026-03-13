import SwiftUI

@main
struct ClipboardHistoryApplication: App {
    @NSApplicationDelegateAdaptor(AppCoordinator.self) private var coordinator

    var body: some Scene {
        Settings {
            SettingsView(settings: coordinator.viewModel.settings) { shortcut in
                coordinator.viewModel.settings.shortcut = shortcut
            }
        }
    }
}
