//
//  FavoritesManager.swift
//  AuraFlow
//
//  Created by Ilya on 28.04.2025.
//

import SwiftUI
import Combine

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published private(set) var favorites: [Meditation] = []
    
    private let storageKey = "favoriteMeditations"
    
    private init() {
        load()
    }
    
    func isFavorite(_ meditation: Meditation) -> Bool {
        favorites.contains(where: { $0.id == meditation.id })
    }
    
    func add(_ meditation: Meditation) {
        guard !isFavorite(meditation) else { return }
        favorites.append(meditation)
        save()
    }
    
    func remove(_ meditation: Meditation) {
        favorites.removeAll { $0.id == meditation.id }
        save()
    }
    
    func toggle(_ meditation: Meditation) {
        isFavorite(meditation) ? remove(meditation) : add(meditation)
    }
    
    private func save() {
        // Сохраняем только идентификаторы, а не весь объект
        let ids = favorites.map { $0.id }
        UserDefaults.standard.set(ids, forKey: storageKey)
    }
    
    private func load() {
        guard let ids = UserDefaults.standard.stringArray(forKey: storageKey) else { return }
        // Здесь предполагаем, что где-то у вас есть источник всех медитаций,
        // например, NetworkService.shared.cachedMeditations или sampleMeditations
        let allMeds = /* ваша коллекция всех медитаций */ sampleMeditations
        favorites = allMeds.filter { ids.contains($0.id) }
    }
    
    func clearAll() {
            favorites.removeAll()
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
}
