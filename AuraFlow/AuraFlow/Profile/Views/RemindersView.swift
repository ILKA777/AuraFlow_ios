//
//  RemindersView.swift
//  Calliope
//
//  Created by Илья on 06.08.2024.
//


import SwiftUI

struct RemindersView: View {
    
    @Environment(\.dismiss) private var dismiss // Access the dismiss environment action
    
    // State variables for toggles and reminders
    @State private var isMotivationEnabled = true
    @State private var isFocusEnabled = true
    @State private var isAppLaunchFocusEnabled = true
    
    @State private var motivationStartTime = Date()
    @State private var motivationEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var motivationFrequency = 2
    
    @State private var focusStartTime = Date()
    @State private var focusEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var focusFrequency = 2
    
    @State private var reminders: [Reminder] = []
    
    // State variables for showing date pickers
    @State private var isStartTimePickerVisible = false
    @State private var isEndTimePickerVisible = false
    
    var body: some View {
        VStack {
            // Reminder settings
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

            // Save button
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
            Image("default") // Replace with your image asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide default back button title
        .toolbar {
            ToolbarItem(placement: .principal) { // Use .principal to customize the title
                Text("Напоминания")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .CalliopeWhite())) // Set the desired color here
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
        .onChange(of: isFocusEnabled) { newValue in
            if newValue {
                isAppLaunchFocusEnabled = true // Set to true when focus practice is enabled
            }
        }
    }
    
    // Function to save reminders
    private func saveReminders() {
        reminders = [
            Reminder(id: UUID(), type: .motivation, startTime: motivationStartTime, endTime: motivationEndTime, frequency: motivationFrequency),
            Reminder(id: UUID(), type: .focus)
        ]
        
        // Сохранение настройки "При открытии приложения" в UserDefaults
        UserDefaults.standard.set(isAppLaunchFocusEnabled, forKey: "launchWithBreathingPractice")
        
        print("Reminders saved: \(reminders)")
    }
    
    // Function to create a reminder card
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
            // Main toggle and optional app launch reminder toggle
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
            
            
            // Time settings and frequency for reminders
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
                            .onTapGesture {
                                isStartTimePickerVisible.wrappedValue.toggle()
                            }
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
                        .changeTextColor(Color(uiColor: .CalliopeWhite()))
                    }
                    
                    HStack {
                        Text("Конец")
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        
                        Spacer()
                        
                        Text(timeString(from: endTime.wrappedValue))
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                            .onTapGesture {
                                isEndTimePickerVisible.wrappedValue.toggle()
                            }
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
                        .changeTextColor(Color(uiColor: .CalliopeWhite()))
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
                                   // .background(Color.gray.opacity(0.2))
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
                                    //.background(Color.gray.opacity(0.2))
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
        .onAppear(perform: loadSettings)
                .onChange(of: isFocusEnabled) { newValue in
                    isAppLaunchFocusEnabled = newValue // Если фокус включен, активируем "При открытии приложения"
                    saveSettings() // Сохраняем изменение
                }
                .onChange(of: isMotivationEnabled) { _ in saveSettings() }
                .onChange(of: isFocusEnabled) { _ in saveSettings() }
                .onChange(of: isAppLaunchFocusEnabled) { _ in saveSettings() }
    }
    
    private func loadSettings() {
            isMotivationEnabled = UserDefaults.standard.bool(forKey: "isMotivationEnabled")
            isFocusEnabled = UserDefaults.standard.bool(forKey: "isFocusEnabled")
            isAppLaunchFocusEnabled = UserDefaults.standard.bool(forKey: "isAppLaunchFocusEnabled")
        }
        
        // Function to save settings to UserDefaults
        private func saveSettings() {
            UserDefaults.standard.set(isMotivationEnabled, forKey: "isMotivationEnabled")
            UserDefaults.standard.set(isFocusEnabled, forKey: "isFocusEnabled")
            UserDefaults.standard.set(isAppLaunchFocusEnabled, forKey: "isAppLaunchFocusEnabled")
        }

    // Function to format time
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        RemindersView()
    }
}
