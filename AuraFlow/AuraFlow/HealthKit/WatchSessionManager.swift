//
//  WatchSessionManager.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // Обработчик при активации сессии
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Ошибка активации WCSession: \(error.localizedDescription)")
        } else {
            print("WCSession успешно активирована с состоянием: \(activationState.rawValue)")
        }
    }
    
    // Обязательный метод для iOS: обработка, если сессия становится неактивной
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Сессия WCSession стала неактивной")
    }
    
    // Обязательный метод для iOS: обработка, если сессия деактивирована
    func sessionDidDeactivate(_ session: WCSession) {
        print("Сессия WCSession деактивирована")
        
        // Если нужно, активируйте сессию снова
        WCSession.default.activate()
    }
}
