//
//  MeditationDurationView.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

struct MeditationDurationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResponseViewModel
    var question = "Какая длительность медитации вам подходит?"
    @StateObject private var playbackManager = PlaybackManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 30) {
                    Text("Какая длительность")
                        .font(Font.custom("Montserrat-MediumItalic", size: 32))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10)
                    
                    Text("вам подходит ?")
                        .font(Font.custom("Montserrat-MediumItalic", size: 32))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10, y: -30)
                    
                }
                .padding(.top, -20)
                VStack(spacing: 16) {
                    NavigationLink(destination: PersonalisedСompilationView(viewModel: viewModel)) {
                        CustomButton(text: "Около 5 минут в день")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Около 5 минут в день")
                    })
                    
                    NavigationLink(destination: PersonalisedСompilationView(viewModel: viewModel)) {
                        CustomButton(text: "10-15 минут в день")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "10-15 минут в день")
                    })
                    
                    NavigationLink(destination: PersonalisedСompilationView(viewModel: viewModel)) {
                        CustomButton(text: "Более 20 минут в день")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Более 20 минут в день")
                    })
                    
                    NavigationLink(destination: PersonalisedСompilationView(viewModel: viewModel)) {
                        CustomButton(text: "Не каждый день")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Не каждый день")
                    })
                }
                .offset(y: -30)
                
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
    MeditationDurationView(viewModel: ResponseViewModel())
}
