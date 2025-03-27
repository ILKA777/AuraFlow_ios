//
//  RegistrationAndAuthorizationViewModel.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import CoreData

struct AlertItem: Identifiable {
    let id = UUID()
    var message: String
}

final class RegistrationAndAuthorizationViewModel: ObservableObject {
    // Поля регистрации/авторизации
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    // Режимы экрана
    @Published var isLoginMode: Bool = false
    @Published var isVerificationMode: Bool = false
    
    // Код подтверждения
    @Published var verificationCode: [String] = Array(repeating: "", count: 4)
    @Published var serverVerificationCode: String = ""
    
    // Для отображения Alert'а (сообщение ошибки)
    @Published var alertMessage: AlertItem?
    
    // URL-адрес сервиса (константа)
    let networkServiceUrl = NetworkService.shared.url
    
    // MARK: - API Методы
    
    func loginUser(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: networkServiceUrl + "auth/signin") else {
            DispatchQueue.main.async {
                self.alertMessage = AlertItem(message: "Некорректный URL.")
            }
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = AlertItem(message: error.localizedDescription)
                }
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = AlertItem(message: "Некорректный ответ сервера.")
                }
                completion(false)
                return
            }

            if httpResponse.statusCode == 200 {
                if let token = String(data: data, encoding: .utf8) {
                    self.saveToken(token)
                    self.fetchUserData(token: token) { success in
                        print("токен авторизации \(token)")
                        completion(success)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = AlertItem(message: "Не удалось извлечь токен.")
                    }
                    completion(false)
                }
            } else {
                if let errorMessage = self.parseErrorMessage(data: data) {
                    DispatchQueue.main.async {
                        self.alertMessage = AlertItem(message: errorMessage)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertMessage = AlertItem(message: "Неизвестная ошибка.")
                    }
                }
                completion(false)
            }
        }.resume()
    }

    func registerUser(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: networkServiceUrl + "auth/signup") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["email": email, "name": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { self.alertMessage?.message = error.localizedDescription }
                completion(false)
                return
            }
            if let data = data, let token = String(data: data, encoding: .utf8) {
                self.saveToken(token)
                // Сохраняем пользователя в CoreData
                CoreDataManager.shared.saveUser(name: self.username, email: self.email)
                DispatchQueue.main.async {
                    // Обновляем данные пользователя сразу после регистрации
                    self.fetchUserData(token: token) { success in
                        
                        completion(success)
                    }
                }
            } else {
                DispatchQueue.main.async { self.alertMessage?.message = "Ошибка регистрации" }
                completion(false)
            }
        }.resume()
    }

    
    func sendConfirmationCode(completion: @escaping (String?) -> Void) {
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
                DispatchQueue.main.async { self.alertMessage?.message = error.localizedDescription }
                completion(nil)
                return
            }
            if let data = data, let code = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.serverVerificationCode = code
                    self.isVerificationMode = true
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
    
    func fetchUserData(token: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: networkServiceUrl + "user") else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { self.alertMessage?.message = error.localizedDescription }
                completion(false)
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { self.alertMessage?.message = "Пустой ответ сервера" }
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let name = json["name"] as? String {
                    CoreDataManager.shared.saveUser(name: name, email: self.email)
                    completion(true)
                } else {
                    DispatchQueue.main.async { self.alertMessage?.message = "Не удалось извлечь данные пользователя" }
                    completion(false)
                }
            } catch {
                DispatchQueue.main.async { self.alertMessage?.message = error.localizedDescription }
                completion(false)
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
            print("Ошибка парсинга: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Валидация
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    // MARK: - Работа с кодом подтверждения
    
    func checkVerificationCode() -> Bool {
        return verificationCode.joined() == serverVerificationCode
    }
    
    func isCodeComplete() -> Bool {
        return verificationCode.allSatisfy { $0.count == 1 }
    }
    
    func moveToNextField(currentIndex: Int, focusedField: inout Int?) {
        if currentIndex < verificationCode.count - 1 {
            focusedField = currentIndex + 1
        } else {
            focusedField = nil
        }
    }
}
