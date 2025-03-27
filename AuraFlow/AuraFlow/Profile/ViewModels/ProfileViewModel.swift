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
    
    private var networkServiceUrl: String = NetworkService.shared.url
    private var authToken: String
    private var urlSessionTask: URLSessionDataTask?
    
    init(authToken: String) {
        self.authToken = authToken
        fetchUserData()
    }
    
    func fetchUserData() {
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
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        urlSessionTask = URLSession.shared.dataTask(with: request) { data, response, error in
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
        }
        urlSessionTask?.resume()
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
