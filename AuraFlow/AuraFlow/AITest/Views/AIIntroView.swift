//
//  AIIntroView.swift
//  Calliope
//
//  Created by Илья on 09.08.2024.
//

import SwiftUI

struct AIIntroView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ResponseViewModel()
    @StateObject private var playbackManager = PlaybackManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: .CalliopeBlack()).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: geometry.size.height * 0.09) {
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.01) {
                        Text("Искусственный интеллект")
                            .font(Font.custom("Montserrat-Regular", size: geometry.size.width * 0.1))
                            .fontWeight(.regular)
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Мы зададим вам ряд вопросов, чтобы выстроить персональные рекомендации")
                            .font(Font.custom("Montserrat-Regular", size: geometry.size.width * 0.05))
                            .fontWeight(.regular)
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, geometry.size.width * 0.06)
                    .padding(.top, geometry.safeAreaInsets.top - geometry.size.height * 0.05)
                    
                    Image("aiCircle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75)
                        .ignoresSafeArea()
                        .offset(y: -20)
                    
                    VStack(spacing: geometry.size.height * 0.02) {
                        NavigationLink(destination: GenderSelectionView(viewModel: viewModel)) {
                            Text("Начать тест")
                                .font(Font.custom("Montserrat-Regular", size: 18))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(30)
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        }
                        .padding(.horizontal, geometry.size.width * 0.06)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Отмена")
                                .font(Font.custom("Montserrat-Regular", size: 18))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        }
                    }
                }
                .background(
                    Image("default")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(.all)
                )
            }
            .onAppear {
                playbackManager.isMiniPlayerVisible = false
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AIIntroView()
}
