//
//  AgeSelectionView.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

struct AgeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResponseViewModel
    @StateObject private var playbackManager = PlaybackManager.shared
    var question = "Ваш возраст"
    
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
                    
                    Text("ваш возраст")
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
                    NavigationLink(destination: MattersMostView(viewModel: viewModel)) {
                        CustomButton(text: "До 21")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "До 21")
                    })
                    
                    NavigationLink(destination: MattersMostView(viewModel: viewModel)) {
                        CustomButton(text: "21-30")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "21-30")
                    })
                    
                    NavigationLink(destination: MattersMostView(viewModel: viewModel)) {
                        CustomButton(text: "31-40")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "31-40")
                    })
                    
                    NavigationLink(destination: MattersMostView(viewModel: viewModel)) {
                        CustomButton(text: "41-60")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "41-60")
                    })
                    
                    NavigationLink(destination: MattersMostView(viewModel: viewModel)) {
                        CustomButton(text: "Больше 60")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.addResponse(question: question, answer: "Больше 60")
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
    AgeSelectionView(viewModel: ResponseViewModel())
}
