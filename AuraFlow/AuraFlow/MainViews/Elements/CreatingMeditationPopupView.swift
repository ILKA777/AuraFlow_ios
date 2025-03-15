//
//  CreatingMeditationPopupView.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI

struct CreatingMeditationPopupView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2.0)
            Text("Создаю медитацию ✨")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
