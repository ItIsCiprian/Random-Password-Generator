import WatchKit

struct HapticsManager {
    static let shared = HapticsManager()

    private init() {}

    func playNotification(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }

    func generateTap() {
        playNotification(.success)
    }

    func copyTap() {
        playNotification(.click)
    }

    func errorTap() {
        playNotification(.failure)
    }

    func toggleTap() {
        playNotification(.directionUp)
    }

    func crownTick() {
        playNotification(.click)
    }

    func deleteTap() {
        playNotification(.notification)
    }
}
