//
//  RegistrationView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI
import CoreData

struct RegistrationAndAuthorizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isUserLoggedIn: Bool
    
    @StateObject private var viewModel = RegistrationAndAuthorizationViewModel()
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Int?
    @MainActor
    var body: some View {
        NavigationStack {
            ZStack {
                // Фоновое изображение
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
                    
                    // Поля ввода в зависимости от режима
                    if viewModel.isLoginMode {
                        loginFields
                    } else if viewModel.isVerificationMode {
                        verificationFields
                    } else {
                        registrationFields
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isLoginMode {
                            viewModel.loginUser { success in
                                if success {
                                    DispatchQueue.main.async {
                                        isUserLoggedIn = true
                                        dismiss()
                                    }
                                }
                            }
                        } else if viewModel.isVerificationMode {
                            if viewModel.isCodeComplete() && viewModel.checkVerificationCode() {
                                viewModel.registerUser { success in
                                    if success {
                                        DispatchQueue.main.async {
                                            isUserLoggedIn = true
                                            dismiss()
                                        }
                                    }
                                }
                            } else {
                                print("Verification code does not match.")
                                
                                DispatchQueue.main.async {
                                    self.viewModel.alertMessage?.message = "Код подтверждения не совпадает."
                                }

                            }
                        } else {
                            if viewModel.validateEmail(viewModel.email) {
                                if viewModel.validatePassword(viewModel.password) {
                                    if viewModel.isPasswordValidFormat(viewModel.password) {
                                        viewModel.sendConfirmationCode { code in
                                            if let code = code {
                                                print("Успешно получили код: \(code)")
                                            } else {
                                                DispatchQueue.main.async {
                                                    self.viewModel.alertMessage = AlertItem(message: "Ошибка при отправке кода.")
                                                }
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            self.viewModel.alertMessage = AlertItem(message: "Пароль должен содержать только латинские буквы, цифры и специальные символы @$!%*?&")
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.viewModel.alertMessage = AlertItem(message: "Пароль должен состоять из 8 символов и должен содержать хотя бы 1 заглавную, 1 прописную латинскую букву, 1 цифру и один спец символ из списка \"@$!%*?&\"")
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.viewModel.alertMessage = AlertItem(message: "Некорректный email.")
                                }
                            }
                        }
                    }) {
                        Text(viewModel.isLoginMode ? "Войти" : viewModel.isVerificationMode ? "Подтвердить" : "Далее")
                            .font(Font.custom("Montserrat-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background((viewModel.isLoginMode || viewModel.isVerificationMode) ? (viewModel.isCodeComplete() ? Color.blue : Color.gray.opacity(0.5)) : Color.blue)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width - 32)

                    // Alert отображается, если в viewModel есть ошибка
                    

                    
                    // Переключение режима
                    Text(viewModel.isLoginMode ? "У меня нет аккаунта" : "У меня уже есть аккаунт")
                        .font(Font.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.white)
                        .underline()
                        .onTapGesture {
                            withAnimation {
                                viewModel.isLoginMode.toggle()
                                viewModel.isVerificationMode = false
                            }
                        }
                    
                    // Кнопка "Отмена"
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Отмена")
                            .font(Font.custom("Montserrat-Regular", size: 18))
                            .foregroundColor(.white)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert(item: $viewModel.alertMessage) { alertItem in
                Alert(
                    title: Text("Ошибка"),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
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
    
    // MARK: - Subviews
    
    private var registrationFields: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .leading) {
                if viewModel.username.isEmpty {
                    Text("Имя пользователя")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 16)
                }
                TextField("", text: $viewModel.username)
                    .textFieldStyle()
            }
            ZStack(alignment: .leading) {
                if viewModel.email.isEmpty {
                    Text("Email")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 16)
                }
                TextField("", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle()
            }
            ZStack(alignment: .leading) {
                if viewModel.password.isEmpty {
                    Text("Пароль")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 16)
                }
                SecureField("", text: $viewModel.password)
                    .textFieldStyle()
            }
        }
    }
    
    private var loginFields: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textFieldStyle()
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle()
        }
    }
    
    private var verificationFields: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                TextField("", text: $viewModel.verificationCode[index])
                    .frame(width: 51, height: 51)
                    .background(Circle().fill(Color.white.opacity(0.1)))
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: index)
                    .onChange(of: viewModel.verificationCode[index]) { newValue in
                        if newValue.count > 1 {
                            viewModel.verificationCode[index] = String(newValue.prefix(1))
                        }
                        if newValue.count == 1 {
                            viewModel.moveToNextField(currentIndex: index, focusedField: &focusedField)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
        }
    }
}

// Вспомогательный модификатор для стиля текстовых полей
extension View {
    func textFieldStyle() -> some View {
        self
            .padding(16)
            .font(Font.custom("Montserrat-Regular", size: 18))
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .frame(maxWidth: UIScreen.main.bounds.width - 32)
    }
}
