import AppKit

@MainActor
final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private weak var viewModel: HistoryViewModel?
    private let onShowHistory: () -> Void
    private let onOpenSetupGuide: () -> Void
    private let onOpenSettings: () -> Void

    init(
        viewModel: HistoryViewModel,
        onShowHistory: @escaping () -> Void,
        onOpenSetupGuide: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onShowHistory = onShowHistory
        self.onOpenSetupGuide = onOpenSetupGuide
        self.onOpenSettings = onOpenSettings
        configure()
    }

    private func configure() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard History")
            button.imagePosition = .imageOnly
        }
        rebuildMenu()
    }

    func rebuildMenu() {
        guard let viewModel else { return }
        let menu = NSMenu()
        let showItem = NSMenuItem(title: "Show History", action: #selector(showHistory), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        let pauseTitle = viewModel.isCapturePaused ? "Resume Capture" : "Pause Capture"
        let pauseItem = NSMenuItem(title: pauseTitle, action: #selector(toggleCapture), keyEquivalent: "")
        pauseItem.target = self
        menu.addItem(pauseItem)

        menu.addItem(.separator())
        let setupItem = NSMenuItem(title: "Setup Guide", action: #selector(openSetupGuide), keyEquivalent: "")
        setupItem.target = self
        menu.addItem(setupItem)

        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    @objc private func showHistory() {
        onShowHistory()
    }

    @objc private func toggleCapture() {
        viewModel?.isCapturePaused.toggle()
        rebuildMenu()
    }

    @objc private func openSettings() {
        onOpenSettings()
    }

    @objc private func openSetupGuide() {
        onOpenSetupGuide()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
