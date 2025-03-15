//
//  MattersMostView.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

struct MattersMostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResponseViewModel
    var question = "Что волунет больше всего ?"
    @StateObject private var playbackManager = PlaybackManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack(spacing: 30) {
                    Text("Что волнует")
                        .font(Font.custom("Montserrat-MediumItalic", size: 40))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10)
                    
                    Text("больше всего ?")
                        .font(Font.custom("Montserrat-MediumItalic", size: 40))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10, y: -40)
                }
                .padding(.top, -20)
                VStack(spacing: 16) {
                    NavigationLink(destination: MeditationSkillsView(viewModel: viewModel)) {
                        CustomButton(text: "Работа и развитие")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Работа и развитие")
                    })
                    
                    NavigationLink(destination: MeditationSkillsView(viewModel: viewModel)) {
                        CustomButton(text: "Внутренний баланс")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Внутренний баланс")
                    })
                    
                    NavigationLink(destination: MeditationSkillsView(viewModel: viewModel)) {
                        CustomButton(text: "Личные отношения")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Личные отношения")
                    })
                    
                    NavigationLink(destination: MeditationSkillsView(viewModel: viewModel)) {
                        CustomButton(text: "Здоровье")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Здоровье")
                    })
                    
                    NavigationLink(destination: MeditationSkillsView(viewModel: viewModel)) {
                        CustomButton(text: "Ситуация с близкими")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Ситуация с близкими")
                    })
                    
                    NavigationLink(destination: MeditationSkillsView(viewModel: viewModel)) {
                        CustomButton(text: "Другое")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Другое")
                    })
                }
                .offset(y: -50)
                
                Spacer()
                
                Button(action: {
                    viewModel.removeLastResponse()
                    dismiss()
                }) {
                    Text("Назад")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .padding(.bottom, 20)
                }
                .padding(.bottom, -20)
            }
            .padding()
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

#Preview {
    MattersMostView(viewModel: ResponseViewModel())
}
