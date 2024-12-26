//
//  RegistrationView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI
import CoreData

struct RegistrationView: View {
    @State private var username: String = ""
    @State private var phoneNumber: String = ""
    @State private var phoneRegion: String = "+7"
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isUserLoggedIn: Bool // Используем для управления логином
    
    @StateObject private var playbackManager = PlaybackManager.shared

    // Состояние для переключения между регистрацией и вводом кода
    @State private var isVerificationMode = false
    @State private var verificationCode: [String] = Array(repeating: "", count: 6)
    
    // Для отслеживания высоты клавиатуры
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Int?

    var body: some View {
        NavigationStack {
            ZStack {
                // Фон
                Image("default")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    // Логотип
                    Image("logo_login")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding(.top, 40)

                    if !isVerificationMode {
                        // Поля для ввода имени и телефона
                        registrationFields
                        
                        // Кнопка "Далее" для перехода к верификации
                        Button(action: {
                            saveUser()
                            withAnimation {
                                isVerificationMode = true
                            }
                        }) {
                            Text("Далее")
                                .font(Font.custom("Montserrat-Regular", size: 18))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color(uiColor: .CalliopeBlack()).opacity(0.3))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .cornerRadius(30)
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width - 32)
                    } else {
                        // Поля для ввода кода подтверждения
                        verificationFields
                        
                        // Кнопка "Войти" для подтверждения кода
                        Button(action: {
                            if isCodeComplete() {
                                isUserLoggedIn = true
                                dismiss() // Возвращаемся на экран ProfileView
                            }
                        }) {
                            Text("Войти")
                                .font(Font.custom("Montserrat-Regular", size: 18))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(isCodeComplete() ? Color(uiColor: .CalliopeYellow()) : Color.gray.opacity(0.5))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width - 32)
                        .disabled(!isCodeComplete())
                    }
                    
                    Spacer()

                    // Кнопка "Отмена"
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Отмена")
                            .font(Font.custom("Montserrat-Regular", size: 18))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(30)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width - 32)
                    .padding(.bottom, 40)
                }
                .offset(y: UIScreen.main.bounds.height == 667 ? keyboardHeight / 2.25 : keyboardHeight / 2.30)
                .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    }
                }
            }
            .onAppear {
                playbackManager.isMiniPlayerVisible = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    keyboardHeight = 0
                }
            }
        }
    }

    // Поля для регистрации
    private var registrationFields: some View {
        VStack {
            ZStack(alignment: .leading) {
                if username.isEmpty {
                    Text("Имя пользователя")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite())) // Placeholder color
                        .padding(12)
                }
                TextField("", text: $username)
                    .padding(16)
                    .font(Font.custom("Montserrat-Regular", size: 18))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(uiColor: .CalliopeWhite()).opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 32)

            HStack {
                TextField("", text: $phoneRegion)
                    .padding()
                    .font(Font.custom("Montserrat-Regular", size: 18))
                    .background(Color(uiColor: .CalliopeWhite()).opacity(0.1))
                    .cornerRadius(30)
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .frame(width: 55)

                ZStack(alignment: .leading) {
                    if phoneNumber.isEmpty {
                        Text("(000) 000-00-00")
                            .font(Font.custom("Montserrat-Regular", size: 18))
                            .foregroundColor(Color(uiColor: .CalliopeWhite())) // Placeholder color
                            .padding(12)
                    }
                    TextField("", text: $phoneNumber)
                        .padding(16)
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(uiColor: .CalliopeWhite()).opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 32)
           // .padding(.vertical, -10)
        }
    }
    
    // Поля для верификации
    private var verificationFields: some View {
        HStack(spacing: 10) {
            ForEach(0..<6) { index in
                TextField("", text: $verificationCode[index])
                    .frame(width: 51, height: 51)
                    .background(Circle().fill(Color(uiColor: .CalliopeWhite()).opacity(0.1)))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .font(Font.custom("Montserrat-Regular", size: 24))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: index)
                    .onChange(of: verificationCode[index]) { newValue in
                        if newValue.count > 1 {
                            verificationCode[index] = String(newValue.prefix(1))
                        }
                        if newValue.count == 1 {
                            moveToNextField(currentIndex: index)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray, lineWidth: 1)
                    )
//                    .overlay(
//                        Text(verificationCode[index].isEmpty ? "_" : verificationCode[index])
//                            .font(.system(size: 24))
//                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
//                            .opacity(0.8)
//                    )
            }
        }
    }
    
    private func saveUser() {
        let newUser = UserCoreData(context: viewContext)
        newUser.name = username
        newUser.phoneNumber = phoneRegion + phoneNumber
        newUser.imageName = "meditationPerson"

        do {
            try viewContext.save()
            print("User saved successfully.")
        } catch {
            print("Failed to save user: \(error.localizedDescription)")
        }
    }
    
    private func moveToNextField(currentIndex: Int) {
        if currentIndex < verificationCode.count - 1 {
            focusedField = currentIndex + 1
        } else {
            focusedField = nil
        }
    }
    
    private func isCodeComplete() -> Bool {
        return verificationCode.allSatisfy { $0.count == 1 }
    }
}
