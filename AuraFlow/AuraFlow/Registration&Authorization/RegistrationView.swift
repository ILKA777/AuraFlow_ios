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
    @State private var networkServiceUrl = NetworkService.shared.url
    
    @Environment(\.dismiss) private var dismiss
    @Binding var isUserLoggedIn: Bool
    
    // Состояния для переключения между режимами
    @State private var isLoginMode = false
    @State private var isVerificationMode = false
    @State private var verificationCode: [String] = Array(repeating: "", count: 4)
    @State private var serverVerificationCode: String = ""
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
                    
                    // Поля для ввода
                    if isLoginMode {
                        loginFields
                    } else if isVerificationMode {
                        verificationFields
                    } else {
                        registrationFields
                    }
                    
                    Spacer()
                    
                    // Основная кнопка действия
                    Button(action: {
                        if isLoginMode {
                            loginUser()
                        } else if isVerificationMode {
                            if isCodeComplete() && checkVerificationCode() {
                                registerUser()
                            } else {
                                print("Verification code does not match.")
                            }
                        } else {
                            if validateEmail(email) {
                                if validatePassword(password) {
                                    sendConfirmationCode(email: email) { code in
                                        if let code = code {
                                            print("Успешно получили код: \(code)")
                                        } else {
                                            print("Ошибка при отправке кода подтверждения.")
                                        }
                                    }
                                } else {
                                    // Отображаем алерт, если пароль не соответствует требованиям
                                    showAlert(
                                        title: "Ошибка",
                                        message: "Пароль должен состоять из 8 символов и должен содержать хотя бы 1 заглавную, 1 прописную латинскую букву, 1 цифру и один спец символ из списка \"@$!%*?&\""
                                    )
                                }
                            } else {
                                print("Некорректный email.")
                            }
                        }
                    }) {
                        Text(isLoginMode ? "Войти" : isVerificationMode ? "Подтвердить" : "Далее")
                            .font(Font.custom("Montserrat-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(isLoginMode || isVerificationMode ? isCodeComplete() ? Color.blue : Color.gray.opacity(0.5) : Color.blue)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width - 32)
                    
                    // Смена режима
                    Text(isLoginMode ? "У меня нет аккаунта" : "У меня уже есть аккаунт")
                        .font(Font.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.white)
                        .underline()
                        .onTapGesture {
                            withAnimation {
                                isLoginMode.toggle()
                                isVerificationMode = false
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
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
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
            ZStack(alignment: .leading) {
                if username.isEmpty {
                    Text("Имя пользователя")
                        .foregroundColor(.white.opacity(0.7)) // Цвет для Placeholder
                        .padding(.leading, 16)
                }
                TextField("", text: $username)
                    .textFieldStyle()
            }
            ZStack(alignment: .leading) {
                if email.isEmpty {
                    Text("Email")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 16)
                }
                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle()
            }
            ZStack(alignment: .leading) {
                if password.isEmpty {
                    Text("Пароль")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 16)
                }
                SecureField("", text: $password)
                    .textFieldStyle()
            }
        }
    }
    
    // Поля для входа
    private var loginFields: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle()
            SecureField("Пароль", text: $password)
                .textFieldStyle()
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Поля для ввода кода подтверждения
    private var verificationFields: some View {
        HStack(spacing: 12) {
            ForEach(0..<4) { index in
                TextField("", text: $verificationCode[index])
                    .frame(width: 51, height: 51)
                    .background(Circle().fill(Color.white.opacity(0.1)))
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
    
    private func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func showAlert(title: String, message: String) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rootViewController.present(alert, animated: true, completion: nil)
    }
    
    
    // Методы для API
    private func loginUser() {
        guard let url = URL(string: networkServiceUrl + "auth/signin") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    showAlert(title: "Ошибка входа", message: error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    showAlert(title: "Ошибка входа", message: "Некорректный ответ сервера.")
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let token = String(data: data, encoding: .utf8) {
                    saveToken(token) // Сохраняем токен
                    fetchUserData(token: token) // Запрос данных пользователя
                } else {
                    DispatchQueue.main.async {
                        showAlert(title: "Ошибка входа", message: "Не удалось извлечь токен.")
                    }
                }
            } else {
                if let errorMessage = parseErrorMessage(data: data) {
                    DispatchQueue.main.async {
                        showAlert(title: "Ошибка входа", message: errorMessage)
                    }
                } else {
                    DispatchQueue.main.async {
                        showAlert(title: "Ошибка входа", message: "Неизвестная ошибка.")
                    }
                }
            }
        }.resume()
    }
    
    private func parseErrorMessage(data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = json["message"] as? String {
                return message
            }
        } catch {
            print("Ошибка парсинга сообщения об ошибке: \(error.localizedDescription)")
        }
        return nil
    }

    
    private func fetchUserData(token: String) {
        guard let url = URL(string: networkServiceUrl + "user") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Передаем токен
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка получения данных пользователя: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Пустой ответ сервера")
                return
            }
            do {
                // Парсим JSON-ответ
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let name = json["name"] as? String {
                    // Сохраняем пользователя в CoreData
                    CoreDataManager.shared.saveUser(name: name, email: self.email)
                    print("Пользователь сохранен: \(name)")
                    DispatchQueue.main.async {
                        self.isUserLoggedIn = true
                        self.dismiss()
                    }
                } else {
                    print("Не удалось извлечь имя пользователя из ответа сервера")
                }
            } catch {
                print("Ошибка парсинга JSON: \(error.localizedDescription)")
            }
        }.resume()
    }


    
    private func registerUser() {
        guard let url = URL(string: networkServiceUrl + "auth/signup") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["email": email, "name": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка регистрации: \(error.localizedDescription)")
                return
            }
            if let data = data, let token = String(data: data, encoding: .utf8) {
                saveToken(token)
                print("токен \(token)")
                CoreDataManager.shared.saveUser(name: username, email: email)
                DispatchQueue.main.async {
                    isUserLoggedIn = true
                    dismiss()
                }
            }
        }.resume()
    }
    
    private func sendConfirmationCode(email: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: networkServiceUrl + "email/send-code") else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка отправки кода: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = data, let code = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    serverVerificationCode = code
                    isVerificationMode = true
                }
                completion(code)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    private func checkVerificationCode() -> Bool {
        return verificationCode.joined() == serverVerificationCode
    }
    
    private func isCodeComplete() -> Bool {
        return verificationCode.allSatisfy { $0.count == 1 }
    }
    
    private func moveToNextField(currentIndex: Int) {
        if currentIndex < verificationCode.count - 1 {
            focusedField = currentIndex + 1
        } else {
            focusedField = nil
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
