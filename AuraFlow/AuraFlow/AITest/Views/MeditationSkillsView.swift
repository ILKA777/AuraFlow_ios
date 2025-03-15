//
//  MeditationSkillsView.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

struct MeditationSkillsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResponseViewModel
    var question = "У вас есть опыт медитаций ?"
    @StateObject private var playbackManager = PlaybackManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 30) {
                    Text("У вас есть опыт")
                        .font(Font.custom("Montserrat-MediumItalic", size: 40))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10)
                    
                    Text("медитаций ?")
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
                    NavigationLink(destination: MeditationDurationView(viewModel: viewModel)) {
                        CustomButton(text: "Нет")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Нет")
                    })
                    
                    NavigationLink(destination: MeditationDurationView(viewModel: viewModel)) {
                        CustomButton(text: "Был, пару раз")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Был, пару раз")
                    })
                    
                    NavigationLink(destination: MeditationDurationView(viewModel: viewModel)) {
                        CustomButton(text: "Да, оффлайн")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Да, оффлайн")
                    })
                    
                    NavigationLink(destination: MeditationDurationView(viewModel: viewModel)) {
                        CustomButton(text: "Да, онлайн")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Да, онлайн")
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
    MeditationSkillsView(viewModel: ResponseViewModel())
}
