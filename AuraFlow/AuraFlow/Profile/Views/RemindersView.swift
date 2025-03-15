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
    
    @StateObject private var viewModel = RemindersViewModel()
    
    // Локальные состояния для показа пикеров времени (отдельно для каждой карточки)
    @State private var isMotivationStartPickerVisible = false
    @State private var isMotivationEndPickerVisible = false
    @State private var isFocusStartPickerVisible = false
    @State private var isFocusEndPickerVisible = false
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                reminderCard(
                    title: "Уведомления",
                    isEnabled: $viewModel.isMotivationEnabled,
                    startTime: $viewModel.motivationStartTime,
                    endTime: $viewModel.motivationEndTime,
                    frequency: $viewModel.motivationFrequency,
                    isStartTimePickerVisible: $isMotivationStartPickerVisible,
                    isEndTimePickerVisible: $isMotivationEndPickerVisible
                )
                
                reminderCard(
                    title: "Практика дыхания",
                    isEnabled: $viewModel.isFocusEnabled,
                    isAppLaunchReminderEnabled: $viewModel.isAppLaunchFocusEnabled,
                    startTime: $viewModel.focusStartTime,
                    endTime: $viewModel.focusEndTime,
                    frequency: $viewModel.focusFrequency,
                    isStartTimePickerVisible: $isFocusStartPickerVisible,
                    isEndTimePickerVisible: $isFocusEndPickerVisible
                )
            }
            .offset(y: 20)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                viewModel.saveReminders()
            }) {
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
        // При изменении состояния уведомлений сохраняем настройки и выполняем доп. действия
        .onChange(of: viewModel.isMotivationEnabled) { newValue in
            if newValue {
                viewModel.requestNotificationPermissionIfNeeded()
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("Уведомления отключены: удалены все запланированные уведомления")
            }
            viewModel.saveSettings()
        }
        .onChange(of: viewModel.isFocusEnabled) { newValue in
            if newValue {
                viewModel.isAppLaunchFocusEnabled = true
            }
            viewModel.saveSettings()
        }
        .onChange(of: viewModel.isAppLaunchFocusEnabled) { _ in
            viewModel.saveSettings()
        }
        .onAppear {
            viewModel.loadSettings()
        }
    }
    
    // MARK: - Subview: Карточка напоминания
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
                if let startTime = startTime,
                   let endTime = endTime,
                   let frequency = frequency,
                   let isStartTimePickerVisible = isStartTimePickerVisible,
                   let isEndTimePickerVisible = isEndTimePickerVisible {
                    
                    Divider().background(Color(uiColor: .CalliopeWhite()))
                    
                    HStack {
                        Text("Начало")
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        Spacer()
                        Text(viewModel.timeString(from: startTime.wrappedValue))
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
                        Text(viewModel.timeString(from: endTime.wrappedValue))
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
