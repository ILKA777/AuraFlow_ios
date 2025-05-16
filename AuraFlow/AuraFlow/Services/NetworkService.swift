//  NetworkService.swift
//  AuraFlow
//
//  Created by Ilya on 01.02.2025.

import Foundation
import SwiftUI

class NetworkService {
    static let shared = NetworkService()
    
    // MARK: – Network-side API-models (JSON)
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
    
    // MARK: – Token
    public func getAuthToken() -> String? {
        guard let token = KeychainService.shared.retrieve(), !token.isEmpty else {
            print("Token not found.")
            return nil
        }
        return token
    }
    
    /// Subscription flag
    func hasSubscription() -> Bool {
        guard let token = getAuthToken() else { return false }
        let key = "subscription_\(token)"
        return UserDefaults.standard.bool(forKey: key)
    }
    
    // MARK: – Fetch Meditations
    func fetchMeditations(completion: @escaping ([Meditation]) -> Void) {
        let endpoint = "\(url)meditation/all"
        guard let requestURL = URL(string: endpoint) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            var meditations: [Meditation] = []
            if let data = data, error == nil,
               let apiModels = try? JSONDecoder().decode([MeditationAPIModel].self, from: data),
               !apiModels.isEmpty {
                meditations = apiModels.map { m in
                    Meditation(
                        id: m.id,
                        title: m.title,
                        author: m.author,
                        date: m.createdAt,
                        duration: "5 минут",
                        videoLink: m.videoLink,
                        audioLink: "",
                        image: UIImage(named: "meditation1") ?? UIImage(),
                        tags: m.tags
                    )
                }
            }
            if meditations.count == 0 {
                let mockURLs = [
                    "https://storage.yandexcloud.net/auraflow/sleepMeditation.mp4",
                    "https://storage.yandexcloud.net/auraflow/workMeditation.mp4",
                    "https://storage.yandexcloud.net/auraflow/morningMeditation.mp4",
                    "https://storage.yandexcloud.net/auraflow/relaxMeditation.mp4",
                    "https://storage.yandexcloud.net/auraflow/shavanaMeditation.mp4"
                ]
                let ids = ["1", "2", "3", "4", "5"]
                
                meditations = zip(ids, mockURLs).map { id, link in
                    let fileName = URL(string: link)?
                        .lastPathComponent
                        .replacingOccurrences(of: ".mp4", with: "")
                    ?? "Meditation"
                    return Meditation(
                        id: id,
                        title: fileName,
                        author: "Сервис",
                        date: DateFormatter
                            .localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                        duration: "5 минут",
                        videoLink: link,
                        audioLink: "",
                        image: UIImage(named: "meditation1") ?? UIImage(),
                        tags: ["RELAX"]
                    )
                }
            }
            DispatchQueue.main.async {
                completion(meditations)
            }
        }.resume()
    }
    
    // MARK: – Fetch Albums
    func fetchAlbums(completion: @escaping ([MeditationAlbum]) -> Void) {
        let endpoint = "\(url)platform-meditation-album/all"
        guard let requestURL = URL(string: endpoint) else { return }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            var albums: [MeditationAlbum] = []
            if let data = data, error == nil,
               let apiAlbums = try? JSONDecoder().decode([AlbumAPIModel].self, from: data),
               !apiAlbums.isEmpty {
                albums = apiAlbums.map { a in
                    let tracks = a.meditations.map { med in
                        Meditation(
                            id: med.id,
                            title: med.title,
                            author: med.author,
                            date: med.createdAt,
                            duration: "5 минут",
                            videoLink: med.videoLink,
                            audioLink: "",
                            image: UIImage(named: "meditation1") ?? UIImage(),
                            tags: med.tags
                        )
                    }
                    return MeditationAlbum(
                        title: a.title,
                        author: tracks.first?.author ?? "Сервис",
                        tracks: tracks,
                        status: "Доступен"
                    )
                }
            }
            // Fallback mocks when empty
            if albums.isEmpty {
                self.fetchMeditations { meds in
                    var mockAlbums: [MeditationAlbum] = []
                    for i in 0..<3 {
                        let slice = Array(meds.dropFirst(i * 2).prefix(2))
                        mockAlbums.append(
                            MeditationAlbum(
                                title: "Альбом \(i+1)",
                                author: "Сервис",
                                tracks: slice,
                                status: "Доступен"
                            )
                        )
                    }
                    DispatchQueue.main.async { completion(mockAlbums) }
                }
                return
            }
            DispatchQueue.main.async { completion(albums) }
        }.resume()
    }
}

// API model for backward compatibility
struct MeditationAPIModel: Decodable {
    let title: String
    let author: String?
    let createdAt: String
    let videoLink: String
    let tags: [String]
}
