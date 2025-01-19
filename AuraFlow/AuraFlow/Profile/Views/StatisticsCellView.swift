//
//  StatisticsCellView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI

struct StatisticsCellView: View {
    var title: LocalizedStringKey = "Статистика"
    var subtitle: String = "Последняя медитация 10 ч назад"
    var progress: String = "1 из 7"
    
    var body: some View {
        ZStack {
            // Background with rounded corners and gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .CalliopeBlack()).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            Color(uiColor: .AuraFlowBlue()),
                            lineWidth: 1 // Adjust the border thickness as needed
                        )
                )
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    // Title
                    Text(title)
                        .font(Font.custom("Montserrat-SemiBold", size: 24))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .offset(x: 10, y: -10)
                    
                    // Subtitle
                    Text(subtitle)
                        .font(Font.custom("Montserrat-Regular", size: 12))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        .offset(x: 10)
                }
                
                Spacer()
                
                // Progress Indicator
                Text(progress)
                    .font(Font.custom("Montserrat-Regular", size: 18))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.9))
                    .offset(x: -10, y: 15)
            }
            .padding()
            
            // Edit Icon
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.9))
                        .padding([.top, .trailing], 8) // Adjust padding to move icon closer to the top-right corner
                        .scaleEffect(x: 1.1, y: 1.1)
                        .offset(x: -20, y: 10)
                }
                Spacer()
            }
        }
        .frame(height: 100) // Set the frame height as needed
        .padding(.horizontal)
        .shadow(color: Color(uiColor: .CalliopeBlack()).opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatisticsCellView()
}
