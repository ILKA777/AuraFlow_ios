//
//  ProfileView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI
import HealthKit

struct ProfileView: View {
    @StateObject private var playbackManager = PlaybackManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @AppStorage("authToken") private var authToken: String = ""
    @StateObject private var viewModel: ProfileViewModel
    
    init() {
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        _viewModel = StateObject(wrappedValue: ProfileViewModel(authToken: token))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView("Загрузка данных...")
                        } else if isUserLoggedIn == false {
                            UserInfoCellView(user: User(name: "······", email: "+7 (999) 000-00-00", imageName: "meditationPerson"))
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .blur(radius: 3)
                            
                            NavigationLink(destination: RegistrationAndAuthorizationView(isUserLoggedIn: $isUserLoggedIn)) {
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
                            if let user = viewModel.user {
                                UserInfoCellView(user: user)
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                            }
                        }
                    }
                    ZStack {
                        NavigationLink(destination: StatisticView()) {
                            StatisticsCellView()
                        }
                    }
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
                        
                        // Переключатель синхронизации с Apple Health
                        Toggle(isOn: $viewModel.isAppleHealthConnected) {
                            Text("Apple Health")
                                .font(Font.custom("Montserrat-Regular", size: 20))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .offset(x: 20)
                        }
                        .onChange(of: viewModel.isAppleHealthConnected) { newValue in
                            if newValue {
                                viewModel.requestHealthKitAccess(healthKitManager: healthKitManager) { _ in }
                            } else {
                                // При отключении сбрасываем настройки
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
                        
                        // Дополнительные переключатели, если Apple Health включен
                        if viewModel.isAppleHealthConnected {
                            Toggle(isOn: $healthKitManager.showPulseDuringVideo) {
                                Text("Отображать пульс во время просмотра видео")
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
                viewModel.fetchUserData()
                viewModel.requestHealthKitAccess(healthKitManager: healthKitManager) { _ in }
            }
            .onDisappear {
                playbackManager.isMiniPlayerVisible = true
                viewModel.cancelRequest()
            }
        }
    }
}
