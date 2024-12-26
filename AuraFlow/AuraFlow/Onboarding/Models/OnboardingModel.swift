//
//  OnboardingModel.swift
//  Calliope
//
//  Created by Илья on 30.07.2024.
//

import SwiftUI

struct OnboardingModel: Identifiable {
    let id = UUID()
    let image: Image
    let title: String
    let description: [String]
}
