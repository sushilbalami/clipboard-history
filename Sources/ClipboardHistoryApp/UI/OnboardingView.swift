import ApplicationServices
import AppKit
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    let onOpenSettings: () -> Void
    let onComplete: () -> Void

    @State private var accessibilityEnabled = AXIsProcessTrusted()
    @State private var hasSetShortcut = false

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.24), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, y: 8)

            VStack(alignment: .leading, spacing: 14) {
                Text("Finish Setup")
                    .font(.title2.weight(.semibold))
                Text("Enable permissions and verify settings so clipboard history can paste into other apps.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                setupRow(
                    title: "Configure shortcut",
                    detail: "Set your preferred global hotkey.",
                    isDone: hasSetShortcut || settings.shortcut != .default,
                    buttonTitle: "Open App Settings",
                    action: {
                        onOpenSettings()
                        hasSetShortcut = true
                    }
                )

                setupRow(
                    title: "Enable Accessibility",
                    detail: "Required for auto-paste after selecting an item.",
                    isDone: accessibilityEnabled,
                    buttonTitle: "Open Accessibility Settings",
                    action: openAccessibilitySettings
                )

                HStack {
                    Button("Refresh Status") {
                        accessibilityEnabled = AXIsProcessTrusted()
                    }
                    Spacer()
                    Button(accessibilityEnabled ? "Done" : "Continue Without Auto-Paste") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 6)
            }
            .padding(18)
        }
        .padding(12)
        .frame(width: 520, height: 360)
        .onReceive(timer) { _ in
            accessibilityEnabled = AXIsProcessTrusted()
        }
    }

    private func setupRow(
        title: String,
        detail: String,
        isDone: Bool,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isDone ? .green : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(buttonTitle, action: action)
                .buttonStyle(.bordered)
        }
        .padding(10)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
