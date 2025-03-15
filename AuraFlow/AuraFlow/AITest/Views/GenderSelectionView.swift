//
//  GenderSelectionView.swift
//  Calliope
//
//  Created by Илья on 09.08.2024.
//

import SwiftUI

struct GenderSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResponseViewModel
    var question = "Ваш пол"
    @StateObject private var playbackManager = PlaybackManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 30) {
                    Text("Укажите")
                        .font(Font.custom("Montserrat-MediumItalic", size: 46))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10)
                    
                    Text("ваш пол")
                        .font(Font.custom("Montserrat-MediumItalic", size: 46))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 10, y: -40)
                }
                .padding(.top, -20)
                VStack(spacing: 16) {
                    NavigationLink(destination: AgeSelectionView(viewModel: viewModel)) {
                        CustomButton(text: "Мужской")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Мужской")
                    })
                    
                    NavigationLink(destination: AgeSelectionView(viewModel: viewModel)) {
                        CustomButton(text: "Женский")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Женский")
                    })
                    
                    NavigationLink(destination: AgeSelectionView(viewModel: viewModel)) {
                        CustomButton(text: "Другое")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Другое")
                    })
                    
                    NavigationLink(destination: AgeSelectionView(viewModel: viewModel)) {
                        CustomButton(text: "Предпочитаю не отвечать")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Предпочитаю не отвечать")
                    })
                }
                .offset(y: -50)
                
                Spacer()
                
                Button(action: {
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
    GenderSelectionView(viewModel: ResponseViewModel())
}
