import AppKit
import ApplicationServices
import Combine
import SwiftUI

@MainActor
final class AppCoordinator: NSObject, ObservableObject, NSApplicationDelegate {
    let viewModel: HistoryViewModel

    private let store: ClipboardStore
    private let monitor: ClipboardMonitor
    private let hotKeyManager: HotKeyManaging
    private let pasteExecutor: PasteExecutor
    private let panelController: HistoryPanelController
    private var settingsWindowController: SettingsWindowController?
    private var statusBarController: StatusBarController?
    private var onboardingController: OnboardingWindowController?
    private var cancellables: Set<AnyCancellable> = []
    private let defaults = UserDefaults.standard

    override init() {
        let store = JSONClipboardStore()
        self.store = store
        let appSettings = AppSettings()
        let viewModel = HistoryViewModel(store: store, settings: appSettings)
        self.viewModel = viewModel
        self.hotKeyManager = GlobalHotKeyManager()
        self.pasteExecutor = SystemPasteExecutor()
        self.panelController = HistoryPanelController(viewModel: viewModel, pasteExecutor: self.pasteExecutor)
        self.monitor = PasteboardMonitor { text, sourceApp in
            Task { @MainActor in
                viewModel.capture(text, sourceApp: sourceApp)
            }
        }
        super.init()
        bindSettings(appSettings)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setApplicationIcon()
        LaunchAtLoginManager.shared.updateEnabled(viewModel.settings.launchAtLogin)
        monitor.start()
        hotKeyManager.onPressed = { [weak self] in
            Task { @MainActor in
                self?.panelController.toggle()
            }
        }
        hotKeyManager.register(viewModel.settings.shortcut)

        statusBarController = StatusBarController(
            viewModel: viewModel,
            onShowHistory: { [weak self] in self?.panelController.toggle() },
            onOpenSetupGuide: { [weak self] in self?.showOnboarding() },
            onOpenSettings: { [weak self] in self?.showSettingsWindow() }
        )
        statusBarController?.rebuildMenu()
        presentOnboardingIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
        hotKeyManager.unregister()
    }

    private func bindSettings(_ settings: AppSettings) {
        settings.$shortcut
            .sink { [weak self] shortcut in
                self?.hotKeyManager.register(shortcut)
            }
            .store(in: &cancellables)

        settings.$launchAtLogin
            .sink { enabled in
                LaunchAtLoginManager.shared.updateEnabled(enabled)
            }
            .store(in: &cancellables)

        viewModel.$isCapturePaused
            .sink { [weak self] _ in
                self?.statusBarController?.rebuildMenu()
            }
            .store(in: &cancellables)
    }

    private func showSettingsWindow() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(
                settings: viewModel.settings,
                onShortcutChange: { [weak self] shortcut in
                    self?.viewModel.settings.shortcut = shortcut
                }
            )
        }
        settingsWindowController?.show()
    }

    private func setApplicationIcon() {
        if let appIcon = NSImage(named: "AppIcon") {
            NSApp.applicationIconImage = appIcon
        }
    }

    private func presentOnboardingIfNeeded() {
        let hasCompleted = defaults.bool(forKey: "hasCompletedOnboarding")
        guard !hasCompleted else { return }
        showOnboarding()
    }

    private func showOnboarding() {
        onboardingController = OnboardingWindowController(
            settings: viewModel.settings,
            onOpenSettings: { [weak self] in self?.showSettingsWindow() },
            onComplete: { [weak self] in
                guard let self else { return }
                self.defaults.set(true, forKey: "hasCompletedOnboarding")
                self.onboardingController?.close()
            }
        )
        onboardingController?.show()
    }
}
