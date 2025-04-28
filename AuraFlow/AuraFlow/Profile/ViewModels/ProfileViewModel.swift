//
//  ProfileViewModel.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import HealthKit

final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var isAppleHealthConnected: Bool = false
    @Published var errorMessage: String? // Для отображения ошибок в UI
    
    private var networkServiceUrl: String = NetworkService.shared.url
    public var authToken: String
    private var urlSessionTask: URLSessionDataTask?
    
    init(authToken: String) {
        self.authToken = authToken
        fetchUserData()
    }
    
    func fetchUserData() {
           guard !authToken.isEmpty else {
               handleError("Токен отсутствует")
               return
           }
        print("токен \(authToken)")
           
           guard let url = URL(string: networkServiceUrl + "user") else {
               handleError("Некорректный URL")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
           
           setLoading(true)
           
           urlSessionTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
               guard let self = self else { return }
               
               if let error = error {
                   self.handleError("Ошибка сети: \(error.localizedDescription)")
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse else {
                   self.handleError("Неверный ответ сервера")
                   return
               }
               
               guard (200...299).contains(httpResponse.statusCode) else {
                   self.handleError("Ошибка сервера: \(httpResponse.statusCode)")
                   return
               }
               
               guard let data = data else {
                   self.handleError("Нет данных в ответе")
                   return
               }
               
               self.parseUserData(data)
           }
           urlSessionTask?.resume()
       }
       
       private func parseUserData(_ data: Data) {
           do {
               if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                   DispatchQueue.main.async {
                       self.user = User(
                           name: json["name"] as? String ?? "Не указано",
                           email: json["email"] as? String ?? "Не указан",
                           imageName: "meditationPerson"
                       )
                       self.setLoading(false)
                   }
               } else {
                   handleError("Некорректный формат данных")
               }
           } catch {
               handleError("Ошибка парсинга: \(error.localizedDescription)")
           }
       }
    
    private func handleError(_ message: String) {
           DispatchQueue.main.async {
               self.errorMessage = message
               self.isLoading = false
               print(message) // Для дебага
           }
       }
    
    private func setLoading(_ loading: Bool) {
          DispatchQueue.main.async {
              self.isLoading = loading
              if !loading {
                  self.errorMessage = nil // Сбрасываем ошибку при завершении загрузки
              }
          }
      }
    
 
    
    func cancelRequest() {
        urlSessionTask?.cancel()
    }
    
    func requestHealthKitAccess(healthKitManager: HealthKitManager, completion: @escaping (Bool) -> Void) {
        healthKitManager.requestAuthorization { authorized in
            DispatchQueue.main.async {
                self.isAppleHealthConnected = authorized
                completion(authorized)
            }
        }
    }
    

}
