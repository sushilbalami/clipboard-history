import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    let onShortcutChange: (ShortcutConfiguration) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                sectionCard(title: "Global Shortcut", subtitle: "Click and press your preferred key combination.") {
                    ShortcutRecorderField(shortcut: $settings.shortcut, onChange: onShortcutChange)
                        .frame(height: 36)
                    Text("Current: \(settings.shortcut.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                sectionCard(title: "Behavior") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Default Return Action")
                                .frame(width: 180, alignment: .leading)
                            Picker("", selection: $settings.defaultAction) {
                                ForEach(PasteActionMode.allCases) { mode in
                                    Text(mode.rawValue.capitalized).tag(mode)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 140)
                        }

                        HStack {
                            Text("Max History Size")
                                .frame(width: 180, alignment: .leading)
                            Stepper(value: $settings.maxHistorySize, in: 20...500, step: 10) {
                                Text("\(settings.maxHistorySize)")
                                    .frame(width: 60, alignment: .leading)
                            }
                        }

                        Toggle("Ignore duplicate consecutive items", isOn: $settings.ignoreDuplicateConsecutiveItems)
                        Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    }
                }

                sectionCard(title: "Permissions", subtitle: "Auto-paste requires Accessibility permission.") {
                    Button("Open Accessibility Settings") {
                        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
                            return
                        }
                        NSWorkspace.shared.open(url)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(18)
        }
        .frame(minWidth: 620, minHeight: 420)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Clipboard History Settings")
                .font(.title3.weight(.semibold))
            Text("Configure shortcut, behavior, and permissions.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func sectionCard<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
