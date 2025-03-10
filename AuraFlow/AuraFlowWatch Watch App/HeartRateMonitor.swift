//
//  HeartRateMonitor.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

#if os(watchOS)
import HealthKit
import WatchConnectivity

class HeartRateMonitor: NSObject, ObservableObject, HKWorkoutSessionDelegate {
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var query: HKAnchoredObjectQuery?

    @Published var heartRate: Double = 0.0

    override init() {
        super.init()
        activateWatchSession()
    }

    func startWorkout() {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutSession?.delegate = self

            workoutSession?.startActivity(with: Date())
            print("Измерения запущено.")

            query = HKAnchoredObjectQuery(
                type: heartRateType,
                predicate: nil,
                anchor: nil,
                limit: HKObjectQueryNoLimit
            ) { [weak self] query, samples, deletedObjects, newAnchor, error in
                self?.process(samples: samples)
            }

            // Добавляем обработчик обновлений
            query?.updateHandler = { [weak self] (query: HKAnchoredObjectQuery, samples: [HKSample]?, deletedObjects: [HKDeletedObject]?, anchor: HKQueryAnchor?, error: Error?) in
                self?.process(samples: samples)
            }

            if let query = query {
                healthStore.execute(query)
                print("Запрос на данные о пульсе выполнен.")
            }
        } catch {
            print("Ошибка запуска измерения: \(error.localizedDescription)")
        }
    }


    func stopWorkout() {
        workoutSession?.end()
        if let query = query {
            healthStore.stop(query)
        }
    }

    private func process(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }

        DispatchQueue.main.async {
            if let lastSample = heartRateSamples.last {
                let heartRate = lastSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                self.heartRate = heartRate

                // Отправляем данные на iPhone
                self.sendHeartRateToPhone(heartRate: heartRate)
            }
        }
    }

    private func activateWatchSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    private func sendHeartRateToPhone(heartRate: Double) {
        if WCSession.default.isReachable {
            let message = ["heartRate": heartRate]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Ошибка отправки данных: \(error.localizedDescription)")
            })
        }
    }

    // MARK: - HKWorkoutSessionDelegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .ended {
            print("Измерение завершена")
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Ошибка измерения: \(error.localizedDescription)")
    }
}

extension HeartRateMonitor: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Ошибка активации WCSession: \(error.localizedDescription)")
        } else {
            print("WCSession успешно активирована.")
        }
    }
}

#endif
