//
//  PersonalisedСompilationView.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

struct PersonalisedСompilationView: View {
    @ObservedObject var viewModel: ResponseViewModel
    @StateObject private var playbackManager = PlaybackManager.shared
    @State private var isNavigatingToMainView = false // Состояние для перехода на MainView
    @State private var selectedTab: TabBarView.Tab = .main
    
    var body: some View {
        NavigationStack {
            VStack {
                // HStack с заголовком и кнопкой закрытия
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Персональная")
                            .font(Font.custom("Montserrat-MediumItalic", size: 35))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                        
                        Text("подборка")
                            .font(Font.custom("Montserrat-MediumItalic", size: 35))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .minimumScaleFactor(0.5)
                            .offset(y: -10) // Настройка вертикального выравнивания
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    
                    // Кнопка закрытия
                    Button(action: {
                        viewModel.removeLastResponse()
                        isNavigatingToMainView = true // Переход на MainView при нажатии
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .font(.title2)
                    }
                    .offset(y: -15)
                }
                .padding(.top, -20)
                .padding(.trailing, 16)
                
                // ScrollView с медитациями
                ScrollView {
                    VStack(spacing: 30) {
                        ForEach(sampleMeditations) { meditation in
                            MeditationView(meditation: meditation)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, -16)
                
                Spacer()
                
                // Кнопка возврата на главную
                NavigationLink(destination: MainView(selectedTab: $selectedTab), isActive: $isNavigatingToMainView) {
                    Text("На главную")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .padding(.bottom, UIScreen.main.bounds.height == 667 ? 20 : 0)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.removeLastResponse()
                    isNavigatingToMainView = true
                })
                .padding(.bottom, -20)
            }
            .padding()
            .background(
                Image("default")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            )
            .onAppear {
                playbackManager.isMiniPlayerVisible = false
            }
            .onDisappear {
                playbackManager.isMiniPlayerVisible = true
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    PersonalisedСompilationView(viewModel: ResponseViewModel())
}
