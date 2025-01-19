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
    @State private var shouldShowHeartRateView = false // Флаг для навигации
    @StateObject private var playbackManager = PlaybackManager.shared
    @State private var user = CoreDataManager.shared.fetchUser()
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false

    private let healthKitManager = HealthKitManager() // Экземпляр менеджера HealthKit

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Top Profile Card
                    ZStack {
                        if !isUserLoggedIn {
                            UserInfoCellView(user: User(name: "······", email: "test@mail.ru", imageName: "meditationPerson"))
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
                            if let user = user, let name = user.name, let email = user.email {
                                UserInfoCellView(user: User(name: name, email: email, imageName: "meditationPerson"))
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                            }
                        }
                    }

                    // Statistics Card
                    ZStack {
                        if !isUserLoggedIn {
                            StatisticsCellView()
                                .blur(radius: 3)

                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(Font.custom("Montserrat-Semibold", size: 22))
                                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                    .offset(x: 15)

                                Text("Статистика недоступна")
                                    .font(Font.custom("Montserrat-Regular", size: 20))
                                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                    .padding()
                            }
                            .cornerRadius(10)
                            .frame(maxWidth: UIScreen.main.bounds.width - 30, maxHeight: .infinity)
                            .background(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                            .cornerRadius(20)
                        } else {
                            StatisticsCellView()
                        }
                    }

                    // Apple Health Toggle
                    Toggle(isOn: $isAppleHealthConnected) {
                        Text("Apple Health")
                            .font(Font.custom("Montserrat-Regular", size: 20))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .offset(x: 20)
                    }
                    .onChange(of: isAppleHealthConnected) { newValue in
                        if newValue {
                            requestHealthKitAccess()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(uiColor: .CalliopeBlack()).opacity(0.1))
                    )
                    .padding(.horizontal)

                    // Footer Options
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                                               healthKitManager.requestAuthorization { success in
                                                   if success {
                                                       shouldShowHeartRateView = true
                                                   } else {
                                                       print("HealthKit authorization failed.")
                                                   }
                                               }
                                           }) {
                                               Text("Test Apple Health")
                                                   .font(Font.custom("Montserrat-Regular", size: 20))
                                                   .foregroundColor(Color.white)
                                                   .padding()
                                                   .frame(maxWidth: .infinity)
                                                   .background(Color.blue)
                                                   .cornerRadius(10)
                                           }
                        .padding(.bottom, -25)

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
            .navigationBarTitle("Профиль", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Профиль")
                        .font(Font.custom("Montserrat-Semibold", size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
            .onAppear {
                playbackManager.isMiniPlayerVisible = false
                user = CoreDataManager.shared.fetchUser()
            }
            .onDisappear {
                playbackManager.isMiniPlayerVisible = true
            }
            .sheet(isPresented: $shouldShowHeartRateView) {
                HeartRateView()
            }
        }
    }

    private func requestHealthKitAccess() {
        healthKitManager.requestAuthorization { success in
            if success {
                shouldShowHeartRateView = true
            } else {
                isAppleHealthConnected = false // Отключить toggle, если доступ не предоставлен
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
