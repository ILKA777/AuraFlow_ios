//
//  NetworkService.swift
//  AuraFlow
//
//  Created by Ilya on 01.02.2025.
//

import Foundation
import SwiftUI

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    var url: String = "https://auraflow-main1-0eeb7f198893.herokuapp.com/"
    
    // Функция для получения токена из хранилища (например, UserDefaults)
    private func getAuthToken() -> String? {
        return "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJtb3Jpbi5pbHlhMjAxNkB5YW5kZXgucnUiLCJpYXQiOjE3NDMwODQ4MTYsImV4cCI6MTc0MzE3MTIxNn0.qU9P1jzj4bI3BZZif8j_15hiDXdFBEJh9hMa8pdpVnXi0VtNwrdACMSEWJcsDBbpFPtlXSwcCKehPozMmoA9PA" // Замените на свой способ получения токена
    }
    
    func fetchMeditations(completion: @escaping ([Meditation]) -> Void) {
        let urlString = "\(url)meditation/all"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Добавляем заголовок с токеном авторизации
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            
            do {
                let meditationsData = try JSONDecoder().decode([MeditationAPIModel].self, from: data)
                let meditations = meditationsData.map { meditation in
                    Meditation(
                        title: meditation.title,
                        author: meditation.author,
                        date: meditation.createdAt,
                        duration: "X минут", // Временно добавляем 0 мин
                        videoLink: meditation.videoLink,
                        image: UIImage(named: "meditation1")!,
                        tags: meditation.tags
                    )
                }
                DispatchQueue.main.async {
                    completion(meditations)
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
    }
}

// Модель, получаемая с API
struct MeditationAPIModel: Decodable {
    let title: String
    let author: String?
    let createdAt: String
    let videoLink: String
    let tags: [String]
}
