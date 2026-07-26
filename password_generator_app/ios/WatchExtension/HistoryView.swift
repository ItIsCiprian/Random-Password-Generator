import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var history: HistoryManager
    @EnvironmentObject var phoneSync: PhoneSyncManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(history.entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.password)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(2)
                            .minimumScaleFactor(0.6)
                        HStack {
                            Text(entry.strengthLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(entry.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 2)
                    .contextMenu {
                        Button {
                            HapticsManager.shared.copyTap()
                            phoneSync.sendPasswordToPhone(entry.password, strengthLabel: entry.strengthLabel)
                        } label: {
                            Label("Send to iPhone", systemImage: "arrow.up.forward")
                        }

                        Button(role: .destructive) {
                            HapticsManager.shared.deleteTap()
                            if let idx = history.entries.firstIndex(where: { $0.id == entry.id }) {
                                history.entries.remove(at: idx)
                                history.save()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            HapticsManager.shared.deleteTap()
                            if let idx = history.entries.firstIndex(where: { $0.id == entry.id }) {
                                history.entries.remove(at: idx)
                                history.save()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            HapticsManager.shared.copyTap()
                            phoneSync.sendPasswordToPhone(entry.password, strengthLabel: entry.strengthLabel)
                        } label: {
                            Label("Send to iPhone", systemImage: "arrow.up.forward")
                        }
                        .tint(.purple)
                    }
                }
                .onDelete { indexSet in
                    HapticsManager.shared.deleteTap()
                    for i in indexSet { history.entries.remove(at: i) }
                    history.save()
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Clear") {
                        HapticsManager.shared.deleteTap()
                        history.clear()
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
}
