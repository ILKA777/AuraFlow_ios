//
//  ProfileView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI
import HealthKit

struct ProfileView: View {
    @State private var isAppleHealthConnected = false
    @Environment(\.dismiss) private var dismiss
    @State private var shouldShowBreathingPractice = false
    @StateObject private var playbackManager = PlaybackManager.shared
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @AppStorage("authToken") private var authToken: String = "" // Храним токен
    @State private var user: User? = nil // Пользовательская модель для отображения данных
    @State private var isLoading = true // Состояние загрузки данных
    
    @State private var networkServiceUrl = NetworkService.shared.url
    
    // Меняем на @StateObject для использования биндингов новых свойств
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    private var urlSessionTask: URLSessionDataTask? // Для отмены запроса при уходе с экрана
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Карточка профиля
                    ZStack {
                        if isLoading {
                            ProgressView("Загрузка данных...")
                        } else if isUserLoggedIn == false {
                            UserInfoCellView(user: User(name: "······", email: "+7 (999) 000-00-00", imageName: "meditationPerson"))
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .blur(radius: 3)
                            
                            NavigationLink(destination: RegistrationView(isUserLoggedIn: $isUserLoggedIn)) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .font(Font.custom("Montserrat-Semibold", size: 22))
                                        .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                        .offset(x: 15)
                                    
                                    Text("Выполните вход в систему")
                                        .font(Font.custom("Montserrat-Regular", size: 20))
                                        .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                        .padding()
                                        .cornerRadius(30)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        } else {
                            if let user = user {
                                UserInfoCellView(user: user)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                            }
                        }
                    }
                    
                    // Карточка статистики
                    ZStack {
                        if isUserLoggedIn == false {
//                            StatisticsCellView()
//                                .blur(radius: 3)
                            
                            NavigationLink(destination: StatisticView()) {
                                StatisticsCellView()
                            }
                            
//                            HStack {
//                                Image(systemName: "lock.fill")
//                                    .font(Font.custom("Montserrat-Semibold", size: 22))
//                                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
//                                    .offset(x: 15)
//                                
//                                Text("Статистика недоступна")
//                                    .font(Font.custom("Montserrat-Regular", size: 20))
//                                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
//                                    .padding()
//                            }
//                            .cornerRadius(10)
//                            .frame(maxWidth: UIScreen.main.bounds.width - 30, maxHeight: .infinity)
//                            .background(Color(uiColor: .CalliopeWhite()).opacity(0.7))
//                            .cornerRadius(20)
                        } else {
                            
                            
                            NavigationLink(destination: StatisticView()) {
                                StatisticsCellView()
                            }
                        }
                    }
                    
                    // Список настроек
                    VStack(spacing: 20) {
                        SettingsItemView(
                            title: "Подписка и покупки",
                            icon: "chevron.right",
                            destination: SubscriptionView()
                        )
                        
                        SettingsItemView(
                            title: "Напоминания",
                            icon: "chevron.right",
                            destination: RemindersView()
                        )
                        
                        // Основной переключатель для синхронизации с Apple Health
                        Toggle(isOn: $isAppleHealthConnected) {
                            Text("Apple Health")
                                .font(Font.custom("Montserrat-Regular", size: 20))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .offset(x: 20)
                        }
                        .onChange(of: isAppleHealthConnected) { newValue in
                            if newValue {
                                requestHealthKitAccess()

                            } else {
                                // Если синхронизация отключена, сбрасываем дополнительные настройки
                                healthKitManager.showPulseDuringVideo = false
                                healthKitManager.showPulseAnalyticsAfterExit = false
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        .padding()
                        .offset(x: -10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(uiColor: .CalliopeBlack()).opacity(0.1))
                        )
                        .padding(.horizontal)
                        
                        
                        // Дополнительные переключатели – появляются только если Apple Health включен
                        if isAppleHealthConnected {
                            Toggle(isOn: $healthKitManager.showPulseDuringVideo) {
                                Text("Отображать пульс во время  просмотра видео")
                                    .font(Font.custom("Montserrat-Regular", size: 18))
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                    .offset(x: 20)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            .padding()
                            .offset(x: -10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color(uiColor: .CalliopeBlack()).opacity(0.1))
                            )
                            .padding(.horizontal)
                            
                            Toggle(isOn: $healthKitManager.showPulseAnalyticsAfterExit) {
                                Text("Показывать аналитику пульса после выхода из плеера")
                                    .font(Font.custom("Montserrat-Regular", size: 18))
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                    .offset(x: 20)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            .padding()
                            .offset(x: -10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color(uiColor: .CalliopeBlack()).opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Footer
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            print("О нас tapped")
                        }) {
                            Text("О нас")
                                .font(Font.custom("Montserrat-Regular", size: 20))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        
                        Button(action: {
                            print("Восстановить покупки tapped")
                        }) {
                            Text("Восстановить покупки")
                                .font(Font.custom("Montserrat-Regular", size: 20))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .background(
                Image("default")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Профиль")
                        .font(Font.custom("Montserrat-Semibold", size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
            .onAppear {
                playbackManager.isMiniPlayerVisible = false
                fetchUserData()
                // При появлении запрашиваем разрешение и обновляем переключатель
                healthKitManager.requestAuthorization { authorized in
                    DispatchQueue.main.async {
                        isAppleHealthConnected = authorized
                    }
                }
            }
            .onDisappear {
                playbackManager.isMiniPlayerVisible = true
                urlSessionTask?.cancel()
            }
        }
    }
    
    private func fetchUserData() {
        guard !authToken.isEmpty else {
            print("Токен отсутствует")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        guard let url = URL(string: networkServiceUrl + "user") else {
            print("Некорректный URL")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        // Начинаем загрузку данных
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка получения данных пользователя: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("Пустой ответ сервера")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                // Парсим JSON-ответ
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let name = json["name"] as? String,
                   let email = json["email"] as? String {
                    DispatchQueue.main.async {
                        self.user = User(name: name, email: email, imageName: "meditationPerson")
                        self.isLoading = false
                    }
                } else {
                    print("Некорректный формат данных")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            } catch {
                print("Ошибка парсинга JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    private func requestHealthKitAccess() {
        healthKitManager.requestAuthorization { success in
            DispatchQueue.main.async {
                isAppleHealthConnected = success
            }
            if !success {
                print("HealthKit authorization failed.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
