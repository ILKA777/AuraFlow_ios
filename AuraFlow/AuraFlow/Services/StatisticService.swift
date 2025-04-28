//
//  StatisticService.swift
//  AuraFlow
//
//  Created by Ilya on 12.03.2025.
//

import SwiftUI

// MARK: - Менеджер статистики с сохранением данных в UserDefaults
class StatisticService: ObservableObject {
    static var shared = StatisticService()
    
    // Целевое количество минут занятий в день
    @Published var targetMinutes: Double = 15 {
        didSet {
            saveTargetMinutes()
        }
    }
    
    // Фактическое количество минут медитаций за сегодня
    @Published var meditationMinutes: Double = 0 {
        didSet {
            updateTodayHistory()
        }
    }
    
    // Словарь для хранения минут за каждый день (ключ: "yyyy-MM-dd")
    private var meditationHistory: [String: Double] = [:]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = .current // или установите нужный часовой пояс
        return df
    }()

    
    // Инициализация: загружаем сохранённые данные и устанавливаем таймер для проверки смены дня
    init() {
        loadData()
        checkForNewDay()
        // Каждую минуту проверяем, не наступил ли новый день
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForNewDay()
        }
    }
    
    // Загрузка данных из UserDefaults
    private func loadData() {
        let defaults = UserDefaults.standard
        
        // Загружаем targetMinutes
        if let savedTarget = defaults.value(forKey: "targetMinutes") as? Double {
            targetMinutes = savedTarget
        }
        
        // Загружаем историю медитаций (если есть)
        if let savedHistory = defaults.dictionary(forKey: "meditationHistory") as? [String: Double] {
            meditationHistory = savedHistory
        }
        
        // Обновляем meditationMinutes для текущего дня
        let todayKey = dateFormatter.string(from: Date())
        meditationMinutes = meditationHistory[todayKey] ?? 0
    }
    
    // Сохранение targetMinutes
    private func saveTargetMinutes() {
        let defaults = UserDefaults.standard
        defaults.set(targetMinutes, forKey: "targetMinutes")
    }
    
    // Обновление данных для текущего дня
    private func updateTodayHistory() {
        let todayKey = dateFormatter.string(from: Date())
        meditationHistory[todayKey] = meditationMinutes
        
        // Оставляем в истории только последние 30 дней
        if let cutoffDate = calendar.date(byAdding: .day, value: -29, to: Date()) {
            for key in meditationHistory.keys {
                if let date = dateFormatter.date(from: key), date < cutoffDate {
                    meditationHistory.removeValue(forKey: key)
                }
            }
        }
        
        // Сохраняем обновлённую историю
        let defaults = UserDefaults.standard
        defaults.set(meditationHistory, forKey: "meditationHistory")
    }
    
    // Проверка смены дня: если в истории для текущего дня нет данных – обнуляем meditationMinutes
    private func checkForNewDay() {
        let todayKey = dateFormatter.string(from: Date())
        if meditationHistory[todayKey] == nil {
            meditationMinutes = 0
        }
    }
    
    // Новый метод для получения количества минут за определённую дату
    func meditationMinutes(for date: Date) -> Double {
        let key = dateFormatter.string(from: date)
        // Если выбранный день – сегодня, возвращаем текущее значение
        if calendar.isDateInToday(date) {
            return meditationMinutes
        } else {
            return meditationHistory[key] ?? 0
        }
    }
}
