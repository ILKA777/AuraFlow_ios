//
//  RemindersView.swift
//  Calliope
//
//  Created by Илья on 06.08.2024.
//


import SwiftUI
import UserNotifications

struct RemindersView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // Состояния для переключателей и настроек уведомлений
    @State private var isMotivationEnabled = true
    @State private var isFocusEnabled = true
    @State private var isAppLaunchFocusEnabled = true
    
    @State private var motivationStartTime = Date()
    @State private var motivationEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    // Значение "периодичность" используется для расчёта интервала между уведомлениями
    @State private var motivationFrequency = 4
    
    @State private var focusStartTime = Date()
    @State private var focusEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var focusFrequency = 2
    
    @State private var reminders: [Reminder] = []
    
    // Состояния для отображения пикеров времени
    @State private var isStartTimePickerVisible = false
    @State private var isEndTimePickerVisible = false
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                reminderCard(
                    title: "Уведомления",
                    isEnabled: $isMotivationEnabled,
                    startTime: $motivationStartTime,
                    endTime: $motivationEndTime,
                    frequency: $motivationFrequency,
                    isStartTimePickerVisible: $isStartTimePickerVisible,
                    isEndTimePickerVisible: $isEndTimePickerVisible
                )
                
                reminderCard(
                    title: "Практика дыхания",
                    isEnabled: $isFocusEnabled,
                    isAppLaunchReminderEnabled: $isAppLaunchFocusEnabled,
                    startTime: $focusStartTime,
                    endTime: $focusEndTime,
                    frequency: $focusFrequency,
                    isStartTimePickerVisible: $isStartTimePickerVisible,
                    isEndTimePickerVisible: $isEndTimePickerVisible
                )
            }
            .offset(y: 20)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: saveReminders) {
                Text("Сохранить")
                    .font(.system(size: 20))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Color(uiColor: .AuraFlowBlue())
                            .cornerRadius(30)
                    )
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(
            Image("default")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Напоминания")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                    print("Back button tapped")
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
        // При изменении состояния уведомлений проверяем разрешения, сохраняем настройки и убираем уведомления при выключении
        .onChange(of: isMotivationEnabled) { newValue in
            if newValue {
                requestNotificationPermissionIfNeeded()
            } else {
                // Если уведомления выключены, удаляем все запланированные уведомления
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("Уведомления отключены: удалены все запланированные уведомления")
            }
            saveSettings()
        }
        .onChange(of: isFocusEnabled) { newValue in
            if newValue {
                isAppLaunchFocusEnabled = true
            }
            saveSettings()
        }
        .onChange(of: isAppLaunchFocusEnabled) { _ in saveSettings() }
        .onAppear(perform: loadSettings)
    }
    
    // Сохранение настроек и планирование уведомлений
    private func saveReminders() {
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
    
    // Проверка и запрос разрешения на уведомления, если оно не было получено ранее
    private func requestNotificationPermissionIfNeeded() {
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
    
    // Планирование уведомлений, которые будут повторяться каждый день
    private func scheduleNotificationsDaily(startTime: Date, endTime: Date, frequency: Int) {
        let calendar = Calendar.current
        // Вычисляем общее количество минут между началом и концом
        guard let totalMinutes = calendar.dateComponents([.minute], from: startTime, to: endTime).minute, totalMinutes > 0 else {
            print("Некорректный промежуток времени")
            return
        }
        // Интервал между уведомлениями (в минутах)
        let intervalMinutes = totalMinutes / frequency
        
        var notificationTimes: [DateComponents] = []
        var currentTime = startTime
        
        // Планируем уведомления от времени начала до конца (всего будет frequency+1 уведомление)
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
    
    // Загрузка настроек из UserDefaults
    private func loadSettings() {
        isMotivationEnabled = UserDefaults.standard.bool(forKey: "isMotivationEnabled")
        isFocusEnabled = UserDefaults.standard.bool(forKey: "isFocusEnabled")
        isAppLaunchFocusEnabled = UserDefaults.standard.bool(forKey: "isAppLaunchFocusEnabled")
    }
    
    // Сохранение настроек в UserDefaults
    private func saveSettings() {
        UserDefaults.standard.set(isMotivationEnabled, forKey: "isMotivationEnabled")
        UserDefaults.standard.set(isFocusEnabled, forKey: "isFocusEnabled")
        UserDefaults.standard.set(isAppLaunchFocusEnabled, forKey: "isAppLaunchFocusEnabled")
    }
    
    // Форматирование времени в строку "HH:mm"
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // Функция для построения карточки напоминания
    @ViewBuilder
    private func reminderCard(
        title: String,
        isEnabled: Binding<Bool>,
        isAppLaunchReminderEnabled: Binding<Bool>? = nil,
        startTime: Binding<Date>? = nil,
        endTime: Binding<Date>? = nil,
        frequency: Binding<Int>? = nil,
        isStartTimePickerVisible: Binding<Bool>? = nil,
        isEndTimePickerVisible: Binding<Bool>? = nil
    ) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .font(Font.custom("Montserrat-Regular", size: 22))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                Spacer()
                Toggle("", isOn: isEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(uiColor: .AuraFlowBlue())))
                    .labelsHidden()
            }
            
            if let isAppLaunchReminderEnabled = isAppLaunchReminderEnabled, isEnabled.wrappedValue {
                Toggle("При открытии приложения", isOn: isAppLaunchReminderEnabled)
                    .font(Font.custom("Montserrat-Regular", size: 16))
                    .toggleStyle(SwitchToggleStyle(tint: Color(uiColor: .AuraFlowBlue())))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
            }
            
            if isEnabled.wrappedValue && (isAppLaunchReminderEnabled == nil || (isAppLaunchReminderEnabled != nil && !isAppLaunchReminderEnabled!.wrappedValue)) {
                if let startTime = startTime, let endTime = endTime, let frequency = frequency, let isStartTimePickerVisible = isStartTimePickerVisible, let isEndTimePickerVisible = isEndTimePickerVisible {
                    
                    Divider().background(Color(uiColor: .CalliopeWhite()))
                    
                    HStack {
                        Text("Начало")
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        Spacer()
                        Text(timeString(from: startTime.wrappedValue))
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                            .onTapGesture { isStartTimePickerVisible.wrappedValue.toggle() }
                    }
                    
                    Divider().background(Color(uiColor: .CalliopeWhite()))
                    
                    if isStartTimePickerVisible.wrappedValue {
                        DatePicker(
                            "Выберите время начала",
                            selection: startTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Text("Конец")
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        Spacer()
                        Text(timeString(from: endTime.wrappedValue))
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                            .onTapGesture { isEndTimePickerVisible.wrappedValue.toggle() }
                    }
                    
                    Divider().background(Color(uiColor: .CalliopeWhite()))
                    
                    if isEndTimePickerVisible.wrappedValue {
                        DatePicker(
                            "Выберите время окончания",
                            selection: endTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Text("Периодичность")
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        Spacer()
                        HStack(spacing: 10) {
                            Button(action: {
                                if frequency.wrappedValue > 1 {
                                    frequency.wrappedValue -= 1
                                }
                            }) {
                                Text("-")
                                    .font(Font.custom("Montserrat-Regular", size: 16))
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                    .frame(width: 24, height: 24)
                                    .cornerRadius(12)
                            }
                            
                            Text("\(frequency.wrappedValue)")
                                .font(Font.custom("Montserrat-Regular", size: 20))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            
                            Button(action: {
                                frequency.wrappedValue += 1
                            }) {
                                Text("+")
                                    .font(Font.custom("Montserrat-Regular", size: 16))
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                    .frame(width: 24, height: 24)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.trailing, -8)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.gray.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        RemindersView()
    }
}
