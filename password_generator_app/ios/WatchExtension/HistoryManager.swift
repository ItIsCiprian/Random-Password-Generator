import Foundation
import ClockKit

struct HistoryEntry: Codable, Identifiable {
    let id: UUID
    let password: String
    let timestamp: Date
    let strengthLabel: String

    init(password: String, strengthLabel: String) {
        self.id = UUID()
        self.password = password
        self.timestamp = Date()
        self.strengthLabel = strengthLabel
    }
}

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    private let maxHistory = 50
    private let defaults = UserDefaults.standard
    private let key = "watch_password_history"

    @Published var entries: [HistoryEntry] = []

    private init() { load() }

    func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return }
        entries = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: key)
        reloadComplications()
    }

    func add(_ password: String, strengthLabel: String) {
        entries.insert(HistoryEntry(password: password, strengthLabel: strengthLabel), at: 0)
        if entries.count > maxHistory { entries = Array(entries.prefix(maxHistory)) }
        save()
    }

    func clear() {
        entries.removeAll()
        save()
    }

    private func reloadComplications() {
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
    }
}
