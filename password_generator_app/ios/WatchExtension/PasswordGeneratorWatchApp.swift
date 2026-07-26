import SwiftUI

@main
struct PasswordGeneratorWatchApp: App {
    @StateObject private var history = HistoryManager.shared
    @StateObject private var phoneSync = PhoneSyncManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(history)
                .environmentObject(phoneSync)
        }
    }
}
