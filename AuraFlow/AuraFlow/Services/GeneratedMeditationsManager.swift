//
//  GeneratedMeditationsManager.swift
//  AuraFlow
//
//  Created by Ilya on 28.04.2025.
//


import Foundation
import SwiftUI

final class GeneratedMeditationsManager: ObservableObject {
    static let shared = GeneratedMeditationsManager()
    
    @Published private(set) var generated: [GeneratedMeditation] = []
    private let storageKey = "generatedMeditations"
    
    private init() {
        load()
    }
    
    func add(_ gm: GeneratedMeditation) {
        generated.append(gm)
        save()
    }
    
    private func save() {
        // сохраняем массив словарей
        let dicts = generated.map { ["id": $0.id, "videoUrl": $0.videoUrl, "name": $0.name] }
        UserDefaults.standard.set(dicts, forKey: storageKey)
    }
    
    private func load() {
        guard let arr = UserDefaults.standard.array(forKey: storageKey) as? [[String:String]] else { return }
        generated = arr.compactMap { dict in
            guard let id = dict["id"], let url = dict["videoUrl"], let name = dict["name"] else { return nil }
            return GeneratedMeditation(id: id, videoUrl: url, name: name)
        }
    }
    
    func clearAll() {
            generated.removeAll()
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
}

struct GeneratedMeditation: Identifiable, Codable {
    let id: String
    let videoUrl: String
    let name: String
}
