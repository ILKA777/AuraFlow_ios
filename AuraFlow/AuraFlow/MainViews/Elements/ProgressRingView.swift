//
//  ProgressRingView.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import UIKit

struct ProgressRingView: View {
    var progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
            Circle()
                .trim(from: 0, to: min(progress, 1))
                .stroke(
                    Color(uiColor: .AuraFlowBlue()),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
            Text("\(Int(min(progress, 1) * 100))%")
                .font(Font.custom("Montserrat-Semibold", size: 20))
                .foregroundColor(Color(uiColor: .AuraFlowBlue()))
        }
    }
}
