//
//  OnboardingItemView.swift
//  Calliope
//
//  Created by Илья on 30.07.2024.
//

import SwiftUI

struct OnboardingItemView: View {
    
    let data: OnboardingModel
    let isLastSlide: Bool
    
    var body: some View {
        ZStack {
            data.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 5)
            
            VStack(alignment: .leading) {
                Spacer()
                
                Text(data.title)
                    .font(Font.custom("Montserrat-MediumItalic", size: 43))
                    .foregroundStyle(Color(uiColor: .CalliopeBlack()))
                    .lineLimit(3)
                
                Spacer()
                    .frame(height: 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(data.description, id: \.self) { line in
                        HStack(alignment: .top) {
                            if isLastSlide {
                                Circle()
                                    .fill(Color(uiColor: .AuraFlowBlue()))
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 4)
                            }
                            
                            Text(line)
                                .font(Font.custom("Montserrat-Regular", size: 20))
                                .foregroundStyle(Color(uiColor: .CalliopeBlack()))
                        }
                    }
                }
            }
            .foregroundColor(Color(uiColor: .CalliopeWhite()))
            .padding(.horizontal, 10)
            .padding(.bottom, 120)
        }
    }
}
