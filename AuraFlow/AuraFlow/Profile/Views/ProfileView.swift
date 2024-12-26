//
//  ProfileView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI


struct ProfileView: View {
    @State private var isAppleHealthConnected = false
    @State private var selectedLanguage = "Русский"
    @Environment(\.dismiss) private var dismiss // Access the dismiss environment action
    @State private var shouldShowBreathingPractice = false
    
    @StateObject private var playbackManager = PlaybackManager.shared
    
    @State private var user = CoreDataManager.shared.fetchUser()
    
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    
    @State private var navigateToMainView = false  // Для управления навигацией
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Top Profile Card
                    ZStack {
                        if !isUserLoggedIn {
                            UserInfoCellView(user: User(name: "······", phoneNumber: "+7 (999) 000-00-00", imageName: "meditationPerson"))
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
                            if let user = user, let name = user.name, let phoneNumber = user.phoneNumber  {
                                UserInfoCellView(user: User(name: name, phoneNumber: phoneNumber, imageName: "meditationPerson"))
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
                    
                    // Other settings list
                    VStack(spacing: 20) {
                        // Subscription and Purchases with Gradient Border
                        SettingsItemView(
                            title: "Подписка и покупки",
                            icon: "chevron.right",
                            destination: SubscriptionView()
                        )
                        
                        // Normal items without gradient border
                        SettingsItemView(
                            title: "Напоминания",
                            icon: "chevron.right",
                            destination: RemindersView() // Example view for navigation
                        )
                        
                        // Apple Health Toggle
                        Toggle(isOn: $isAppleHealthConnected) {
                            Text("Apple Health")
                                .font(Font.custom("Montserrat-Regular", size: 20))
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
                        
                        //                        SettingsItemView(
                        //                            title: "Тестирование плеера",
                        //                            icon: "chevron.right",
                        //                            destination: StartView(
                        //                                videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                        //                                onPracticeCompleted: {
                        //                                    shouldShowBreathingPractice = false // Закрыть StartView и вернуться в MainView
                        //                                }
                        //                            )
                        //                        )
                    }
                    
                    // Footer Options
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
                    .padding(.leading, 20)  // Padding from the left edge
                    .padding(.bottom, 20)   // Padding from the bottom
                }
                .padding(.top)
            }
            .background(
                // Set the background image
                Image("default") // Replace with your image asset name
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            //.navigationTitle("Профиль")
            .navigationBarBackButtonHidden(true) // Hide default back button title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { // Use .principal to customize the title
                    Text("Профиль")
                        .font(Font.custom("Montserrat-Semibold", size: 20))
                        .font(.headline)
                        .foregroundColor(Color(uiColor: .CalliopeWhite())) // Set the desired color here
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    }
                    //                    .navigationDestination(isPresented: $navigateToMainView) {
                    //                        MainView()
                    //                    }
                }
            }
            .onAppear {
                playbackManager.isMiniPlayerVisible = false
                
                user = CoreDataManager.shared.fetchUser() // Обновляем данные пользователя
                
            }
            .onDisappear() {
                playbackManager.isMiniPlayerVisible = true
            }
            
            
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
