//
//  DayProgressPopupView.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import UIKit

struct DayProgressPopupView: View {
    var meditationMinutes: Double
    var targetMinutes: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressRingView(progress: CGFloat(meditationMinutes / targetMinutes))
                .frame(width: 100, height: 200)
            
            Text("В этот день вы были активны \(Int(meditationMinutes)) минут из \(Int(targetMinutes))")
                .font(Font.custom("Montserrat-Regular", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
