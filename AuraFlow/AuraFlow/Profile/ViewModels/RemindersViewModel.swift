//
//  RemindersViewModel.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import UserNotifications

final class RemindersViewModel: ObservableObject {
    // MARK: - Настройки уведомлений
    @Published var isMotivationEnabled: Bool = true
    @Published var isFocusEnabled: Bool = true
    @Published var isAppLaunchFocusEnabled: Bool = true

    @Published var motivationStartTime: Date = Date()
    @Published var motivationEndTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @Published var motivationFrequency: Int = 4

    @Published var focusStartTime: Date = Date()
    @Published var focusEndTime: Date = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @Published var focusFrequency: Int = 2

    @Published var reminders: [Reminder] = []

    // MARK: - Сохранение напоминаний и настроек

    func saveReminders() {
        // Создаём напоминания (пример для мотивационных и для практики дыхания)
        reminders = [
            Reminder(id: UUID(), type: .motivation, startTime: motivationStartTime, endTime: motivationEndTime, frequency: motivationFrequency),
            Reminder(id: UUID(), type: .focus)
        ]
        
        // Сохраняем настройку "При открытии приложения" в UserDefaults
        UserDefaults.standard.set(isAppLaunchFocusEnabled, forKey: "launchWithBreathingPractice")
        
        print("Reminders saved: \(reminders)")
        
        // Если уведомления включены, планируем их на каждый день
        if isMotivationEnabled {
            scheduleNotificationsDaily(startTime: motivationStartTime, endTime: motivationEndTime, frequency: motivationFrequency)
        }
    }
    
    func requestNotificationPermissionIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("Ошибка при запросе разрешения: \(error.localizedDescription)")
                    } else if granted {
                        print("Разрешение на уведомления получено")
                    } else {
                        print("Разрешение на уведомления отклонено")
                    }
                }
            }
        }
    }
    
    func scheduleNotificationsDaily(startTime: Date, endTime: Date, frequency: Int) {
        let calendar = Calendar.current
        guard let totalMinutes = calendar.dateComponents([.minute], from: startTime, to: endTime).minute, totalMinutes > 0 else {
            print("Некорректный промежуток времени")
            return
        }
        
        // Интервал между уведомлениями (в минутах)
        let intervalMinutes = totalMinutes / frequency
        var notificationTimes: [DateComponents] = []
        var currentTime = startTime
        
        // Планируем уведомления от начала до конца (frequency+1 уведомление)
        for _ in 0...frequency {
            let comp = calendar.dateComponents([.hour, .minute], from: currentTime)
            notificationTimes.append(comp)
            if let nextTime = calendar.date(byAdding: .minute, value: intervalMinutes, to: currentTime) {
                currentTime = nextTime
            } else {
                break
            }
        }
        
        let center = UNUserNotificationCenter.current()
        // Удаляем ранее запланированные уведомления
        center.removeAllPendingNotificationRequests()
        
        for comp in notificationTimes {
            let content = UNMutableNotificationContent()
            content.title = "Напоминание"
            // Подбираем текст уведомления по часу
            if let hour = comp.hour {
                if hour >= 7 && hour < 12 {
                    content.body = "Прекрасное утро! Не хотите ли зарядиться энергией? Заходите к нам!"
                } else if hour >= 12 && hour < 16 {
                    content.body = "Обеденный перерыв? Есть минутка для медитаций?"
                } else if hour >= 16 && hour < 24 {
                    content.body = "Расслабься и успокойся с нашими медитациями."
                } else {
                    content.body = "Кажется, кто-то не спит? У нас есть отличные медитации, которые помогут уснуть."
                }
            }
            content.sound = .default
            
            // Для повторяющихся уведомлений указываем только часы и минуты, repeats: true
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Загрузка/сохранение настроек в UserDefaults
    
    func loadSettings() {
        isMotivationEnabled = UserDefaults.standard.bool(forKey: "isMotivationEnabled")
        isFocusEnabled = UserDefaults.standard.bool(forKey: "isFocusEnabled")
        isAppLaunchFocusEnabled = UserDefaults.standard.bool(forKey: "isAppLaunchFocusEnabled")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isMotivationEnabled, forKey: "isMotivationEnabled")
        UserDefaults.standard.set(isFocusEnabled, forKey: "isFocusEnabled")
        UserDefaults.standard.set(isAppLaunchFocusEnabled, forKey: "isAppLaunchFocusEnabled")
    }
    
    // MARK: - Вспомогательная функция форматирования даты
    
    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
