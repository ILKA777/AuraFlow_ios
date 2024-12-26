//
//  OverlayView.swift
//  Calliope
//
//  Created by Илья on 07.08.2024.
//

import SwiftUI

struct OverlayView: View {
    var title: String
    var isLocked: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color(uiColor: .CalliopeBlack()).opacity(0.4)
            
            VStack {
                HStack {
                    Image(systemName: isLocked ? "lock.fill" : "exclamationmark.triangle")
                        .foregroundColor(Color(uiColor: .CalliopeBlack()))
                    
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(uiColor: .CalliopeBlack()))
                        .padding(.leading, 5)
                    
                    Spacer()
                }
                .padding()
                .background(Color(uiColor: .CalliopeWhite()).opacity(0.8))
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Match parent view size
        .cornerRadius(20)
    }
}

#Preview {
    OverlayView(title: "Выполните вход в систему", isLocked: true)
        .frame(width: 300, height: 100) // Example frame size for preview
}
