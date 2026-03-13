import ApplicationServices
import SwiftUI

struct HistoryPanelView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Binding var selectedID: ClipboardEntry.ID?

    let onMinimize: () -> Void
    let onClose: () -> Void
    let onDismiss: () -> Void
    let onPerform: (ClipboardEntry, PasteActionMode) -> Void

    @State private var isHovering = false
    @State private var hasAccessibilityPermission = AXIsProcessTrusted()
    private let permissionRefreshTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )

            VStack(spacing: 12) {
                header
                searchField
                if viewModel.settings.defaultAction == .paste && !hasAccessibilityPermission {
                    permissionWarning
                }
                entriesList
                footer
            }
            .padding(16)
        }
        .padding(10)
        .onKeyPress(.escape) {
            onDismiss()
            return .handled
        }
        .onKeyPress(.upArrow) {
            moveSelection(up: true)
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveSelection(up: false)
            return .handled
        }
        .onKeyPress(.return) {
            guard let selected = currentSelection else { return .ignored }
            onPerform(selected, viewModel.settings.defaultAction)
            return .handled
        }
        .onAppear {
            refreshPermissionState()
        }
        .onReceive(permissionRefreshTimer) { _ in
            refreshPermissionState()
        }
        .animation(.easeInOut(duration: 0.15), value: viewModel.filteredEntries.count)
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Circle()
                    .fill(Color.red.opacity(0.9))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.black.opacity(0.24), lineWidth: 0.6))
            }
            .buttonStyle(.plain)

            Button(action: onMinimize) {
                Circle()
                    .fill(Color.yellow.opacity(0.88))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color.black.opacity(0.24), lineWidth: 0.6))
            }
            .buttonStyle(.plain)

            Label("Clipboard History", systemImage: "doc.on.clipboard")
                .font(.headline)
            Spacer()
            if let message = viewModel.lastActionMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var searchField: some View {
        TextField("Search clipboard history", text: $viewModel.searchQuery)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }

    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredEntries) { entry in
                    row(for: entry)
                }
                if viewModel.filteredEntries.isEmpty {
                    Text("No clipboard items yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Text("↩ uses \(viewModel.settings.defaultAction == .paste ? "Paste" : "Copy")")
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(viewModel.settings.shortcut.displayName) to open")
                .foregroundStyle(.secondary)
        }
        .font(.caption)
    }

    private var permissionWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundStyle(.yellow)
            Text("Enable Accessibility for auto-paste. If you just enabled it, relaunch Clipboard History once.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.yellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func row(for entry: ClipboardEntry) -> some View {
        let selected = selectedID == entry.id
        return Button {
            selectedID = entry.id
            onPerform(entry, .paste)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: entry.isPinned ? "pin.fill" : "doc.text")
                    .foregroundStyle(entry.isPinned ? .yellow : .secondary)
                    .frame(width: 16)
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.plainTextPreview.replacingOccurrences(of: "\n", with: " "))
                        .lineLimit(2)
                        .font(.callout)
                    HStack(spacing: 8) {
                        if let sourceApp = entry.sourceApp {
                            Text(sourceApp)
                        }
                        Text(entry.timestamp, style: .time)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 8) {
                    actionIcon("doc.on.doc") { onPerform(entry, .copy) }
                    actionIcon(entry.isPinned ? "pin.slash" : "pin") { viewModel.togglePinned(entry) }
                    actionIcon("trash") { viewModel.delete(entry) }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selected ? Color.accentColor.opacity(0.25) : Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(selected ? 0.3 : 0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
            if hovering { selectedID = entry.id }
        }
    }

    private func actionIcon(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 22, height: 22)
                .background(Color.black.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private var currentSelection: ClipboardEntry? {
        if let selectedID, let selected = viewModel.filteredEntries.first(where: { $0.id == selectedID }) {
            return selected
        }
        return viewModel.filteredEntries.first
    }

    private func moveSelection(up: Bool) {
        guard !viewModel.filteredEntries.isEmpty else { return }
        guard let selectedID,
              let currentIndex = viewModel.filteredEntries.firstIndex(where: { $0.id == selectedID }) else {
            self.selectedID = viewModel.filteredEntries.first?.id
            return
        }

        let nextIndex: Int
        if up {
            nextIndex = max(0, currentIndex - 1)
        } else {
            nextIndex = min(viewModel.filteredEntries.count - 1, currentIndex + 1)
        }
        self.selectedID = viewModel.filteredEntries[nextIndex].id
    }

    private func refreshPermissionState() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }
}
