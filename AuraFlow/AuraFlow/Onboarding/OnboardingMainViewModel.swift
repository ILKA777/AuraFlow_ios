//
//  OnboardingMainViewModel.swift
//  Calliope
//
//  Created by Илья on 30.07.2024.
//

import SwiftUI

class OnboardingMainViewModel: ObservableObject {
    @Published var onboardingData: [OnboardingModel] = []
    
    func fillData() {
        onboardingData = [
            OnboardingModel(image: Image(.calliopeOnboardingFirst), title: "Начните\nзаботиться\nо себе", description: ["Мы знаем, как достичь поставленных целей, снять стресс и вовремя отдохнуть"]),
            OnboardingModel(image: Image(.calliopeOnboardingSecond), title: "Первый шаг навстречу осознанности", description: ["Большинство современных психологов рекомендуют регулярные медитации"]),
            OnboardingModel(image: Image(.calliopeOnboardingThird), title: "Добро\nпожаловать\nв AuraFlow", description: ["100+ медитаций", "новые занятия каждую неделю", "ИИ-подбор"]) // Array for list
        ]
    }
}
