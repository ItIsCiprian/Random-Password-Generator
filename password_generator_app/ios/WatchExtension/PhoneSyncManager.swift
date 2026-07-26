import Foundation
import WatchConnectivity

class PhoneSyncManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneSyncManager()

    @Published var isReachable = false

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.isReachable = session.isReachable }
    }

    func sendPasswordToPhone(_ password: String, strengthLabel: String) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage([
            "action": "add_history",
            "password": password,
            "strengthLabel": strengthLabel,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ], replyHandler: nil)
    }
}
