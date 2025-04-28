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
    
    // MARK: – Network‑side API‑модели (JSON)

    private struct MeditationAPIModel: Decodable {
        let id: String
        let author: String?
        let title: String
        let description: String?
        let videoLink: String
        let tags: [String]
        let createdAt: String
    }

    private struct AlbumAPIModel: Decodable {
        let id: String
        let title: String
        let description: String?
        let meditations: [MeditationAPIModel]
    }
    
    
    private init() {}
    
    var url: String = "https://auraflow-main1-0eeb7f198893.herokuapp.com/"
    
    // Функция для получения токена из хранилища (например, UserDefaults)
    public func getAuthToken() -> String? {
        guard let token = KeychainService.shared.retrieve() else {
            print("Token not found.")
            return ""
        }
        return token
    }
    
    /// Возвращает true, если для текущего токена есть активная подписка
       func hasSubscription() -> Bool {
           guard let token = getAuthToken(), !token.isEmpty else {
               return false
           }
           let key = "subscription_\(token)"
           return UserDefaults.standard.bool(forKey: key)
       }
    
    
    func fetchMeditations(completion: @escaping ([Meditation]) -> Void) {
        let urlString = "\(url)meditation/all"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Добавляем заголовок с токеном авторизации
        if let token = getAuthToken(), !token.isEmpty {
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
                        duration: "5 минут", // Временно добавляем 0 мин
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
    
    // MARK: – Albums
        func fetchAlbums(completion: @escaping ([MeditationAlbum]) -> Void) {
            let urlString = "\(url)platform-meditation-album/all"
            guard let url = URL(string: urlString) else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = getAuthToken(), !token.isEmpty {
                       request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                   }


            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    print("Error fetching albums: \(String(describing: error))")
                    return
                }
                do {
                    let apiAlbums = try JSONDecoder().decode([AlbumAPIModel].self, from: data)
                    let albums: [MeditationAlbum] = apiAlbums.map { album in
                        // Преобразуем медитации внутри альбома
                        let tracks: [Meditation] = album.meditations.map { med in
                            Meditation(
                                title: med.title,
                                author: med.author,
                                date: med.createdAt,
                                duration: "5 минут", // TODO: duration from backend
                                videoLink: med.videoLink,
                                image: UIImage(named: "meditation1") ?? UIImage(),
                                tags: med.tags
                            )
                        }
                        return MeditationAlbum(
                            title: album.title,
                            author: tracks.first?.author ?? "Unknown",
                            tracks: tracks,
                            status: "Доступен"
                        )
                    }
                    DispatchQueue.main.async { completion(albums) }
                } catch {
                    print("Decoding albums failed: \(error)")
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
