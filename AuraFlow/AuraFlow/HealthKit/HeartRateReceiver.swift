//
//  HeartRateReceiver.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

import WatchConnectivity

class HeartRateReceiver: NSObject, ObservableObject, WCSessionDelegate {
    @Published var heartRate: Double = 0.0

    override init() {
        super.init()
        activateWatchSession()
    }

    private func activateWatchSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Приём сообщений с Apple Watch
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let heartRate = message["heartRate"] as? Double {
            DispatchQueue.main.async {
                self.heartRate = heartRate
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
