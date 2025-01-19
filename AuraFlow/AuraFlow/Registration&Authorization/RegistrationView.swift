//
//  RegistrationView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
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
    @State private var email: String = ""
    @State private var password: String = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isUserLoggedIn: Bool

    @StateObject private var playbackManager = PlaybackManager.shared

    // Состояние для переключения между регистрацией и вводом кода
    @State private var isVerificationMode = false
    @State private var verificationCode: [String] = Array(repeating: "", count: 6)

    // Сохранение кода подтверждения, полученного от сервера
    @State private var serverVerificationCode: String = ""

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
                    
                    Text(isVerificationMode ? "Verification Mode: ON" : "Verification Mode: OFF")
                        .foregroundColor(.white)


                    if !isVerificationMode {
                        // Поля для ввода имени, email и пароля
                        registrationFields
                        
                        // Кнопка "Далее" для перехода к верификации
                        Button(action: {
                            if validateEmail(email) {
                                saveUser()
                                sendConfirmationCode(email: email) { code in
                                    if let code = code {
                                        print("Успешно получили код: \(code)")
                                    } else {
                                        print("Произошла ошибка или код не получен.")
                                    }
                                }


                            } else {
                                print("Invalid email address.")
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
                        
                        // Текст "У меня уже есть аккаунт"
                        Text("У меня уже есть аккаунт")
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(.white)
                            .underline()
                            .onTapGesture {
                                dismiss()
                            }

                    } else {
                        // Поля для ввода кода подтверждения
                        verificationFields
                        
                        // Кнопка "Войти" для подтверждения кода
                        Button(action: {
                            if isCodeComplete() && checkVerificationCode() {
                                registerUser()
                            } else {
                                print("Verification code does not match.")
                            }
                        }) {
                            Text("Войти")
                                .font(Font.custom("Montserrat-Regular", size: 18))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(isCodeComplete() ? Color(uiColor: .AuraFlowBlue()) : Color.gray.opacity(0.5))
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
        VStack(spacing: 16) {
            // Имя пользователя
            ZStack(alignment: .leading) {
                if username.isEmpty {
                    Text("Имя пользователя")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
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

            // Email
            ZStack(alignment: .leading) {
                if email.isEmpty {
                    Text("Email")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        .padding(12)
                }
                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
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
            
            // Пароль
            ZStack(alignment: .leading) {
                if password.isEmpty {
                    Text("Пароль")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        .padding(12)
                }
                SecureField("", text: $password)
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
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func sendConfirmationCode(email: String, completion: @escaping (String?) -> Void) {
        // 1. Формируем URL
        guard let url = URL(string: "http://localhost:8080/email/send-code") else {
            print("Некорректный URL")
            completion(nil)
            return
        }
        
        // 2. Создаём URLRequest с нужными настройками
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Готовим JSON‐тело запроса
        let parameters = ["email": email]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            print("Ошибка сериализации JSON: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        // 4. Отправляем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка сетевых ошибок
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Проверяем код ответа
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Некорректный формат ответа")
                completion(nil)
                return
            }
            
            if httpResponse.statusCode == 201 {
                // Предполагаем, что сервер возвращает 4‐значный код в теле ответа
                if let data = data, let code = String(data: data, encoding: .utf8) {
                    print("Получен код подтверждения: \(code)")
                    completion(code)
                } else {
                    print("Не удалось декодировать тело ответа")
                    completion(nil)
                }
            } else {
                print("Сервер вернул статус \(httpResponse.statusCode)")
                completion(nil)
            }
        }
        
        // Запускаем задачу
        task.resume()
    }



    private func checkVerificationCode() -> Bool {
        return verificationCode.joined() == serverVerificationCode
    }

    private func registerUser() {
        guard let url = URL(string: "http://localhost:8080/auth/signup") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["email": email, "name": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to register user: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.isUserLoggedIn = true
                self.dismiss()
            }
        }.resume()
    }

    private func saveUser() {
        let newUser = UserCoreData(context: viewContext)
        newUser.name = username
        newUser.email = email

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
