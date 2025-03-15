//
//  CreateMeditationViewModel.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI

final class CreateMeditationViewModel: ObservableObject {
    @Published var duration: Double = 5
    @Published var melodyPrompt: String = ""
    @Published var meditationPrompt: String = ""
    @Published var audioPrompt: String = ""
    @Published var selectedVideo: VideoForGeneration? = nil
    
    @Published var showPopup: Bool = false
    @Published var navigateToPlayer: Bool = false
    
    let durations = [5, 10, 15, 20, 30, 45, 60]  // Доступные длительности
    
    // Метод уменьшения длительности
    func decrementDuration() {
        if duration > 0 {
            duration -= 1
        }
    }
    
    // Метод увеличения длительности
    func incrementDuration() {
        if duration < 30 {
            duration += 1
        }
    }
    
    // Метод создания медитации (симуляция с задержкой)
    func createMeditation() {
        showPopup = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showPopup = false
            self.navigateToPlayer = true
        }
        print("Создание медитации с длительностью: \(Int(duration)) минут, промптом для мелодии: \(melodyPrompt), промптом для медитации: \(meditationPrompt)")
    }
}
