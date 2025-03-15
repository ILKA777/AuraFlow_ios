//
//  HealthKitManager.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    static let shared = HealthKitManager()
    
    @Published var showPulseDuringVideo: Bool {
        didSet {
            UserDefaults.standard.set(showPulseDuringVideo, forKey: "showPulseDuringVideo")
        }
    }
    
    @Published var showPulseAnalyticsAfterExit: Bool {
        didSet {
            UserDefaults.standard.set(showPulseAnalyticsAfterExit, forKey: "showPulseAnalyticsAfterExit")
        }
    }
    
    // Инициализируем свойства из UserDefaults, если они там сохранены, иначе false
    private init() {
        if let storedValue = UserDefaults.standard.value(forKey: "showPulseDuringVideo") as? Bool {
            showPulseDuringVideo = storedValue
        } else {
            showPulseDuringVideo = false
        }
        if let storedValue = UserDefaults.standard.value(forKey: "showPulseAnalyticsAfterExit") as? Bool {
            showPulseAnalyticsAfterExit = storedValue
        } else {
            showPulseAnalyticsAfterExit = false
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [heartRateType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, _ in
            DispatchQueue.main.async {
                if success {
                    // Обновляем настройки только если их ещё нет в UserDefaults
                    if UserDefaults.standard.value(forKey: "showPulseDuringVideo") == nil {
                        self.showPulseDuringVideo = true
                    }
                    if UserDefaults.standard.value(forKey: "showPulseAnalyticsAfterExit") == nil {
                        self.showPulseAnalyticsAfterExit = true
                    }
                }
                completion(success)
            }
        }
    }
}
