//
//  OnboardingSliderView.swift
//  Calliope
//
//  Created by Илья on 30.07.2024.
//

import SwiftUI

struct OnboardingSliderView<Content>: View where Content: View {
    
    @Binding var index: Int
    @EnvironmentObject var viewModel: OnboardingMainViewModel
    @State private var offset: CGFloat = .zero
    @State private var dragging: Bool = false
    let content: () -> Content
    
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(viewModel.onboardingData.indices, id: \.self) { i in
                                OnboardingItemView(
                                    data: viewModel.onboardingData[i],
                                    isLastSlide: i == viewModel.onboardingData.count - 1
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                            }
                        }
                    }
                    .content.offset(x: self.offset(in: geometry), y: 0)
                    .frame(width: geometry.size.width, alignment: .leading)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.dragging = true
                                self.offset = -CGFloat(self.index) * geometry.size.width + value.translation.width
                            }
                            .onEnded { value in
                                let predictionEndOffset = -CGFloat(self.index) * geometry.size.width + value.predictedEndTranslation.width
                                let predictedIndex = Int(round(predictionEndOffset / -geometry.size.width))
                                self.index = self.clampedIndex(from: predictedIndex)
                                withAnimation {
                                    self.dragging = false
                                }
                            }
                    )
                    .onTapGesture { location in
                        let tapLocation = location.x
                        if tapLocation < geometry.size.width / 2 {
                            // Tap на левой половине экрана
                            self.index = max(0, self.index - 1) // Переход на предыдущий слайд
                        } else {
                            // Tap на правой половине экрана
                            self.index = min(viewModel.onboardingData.count - 1, self.index + 1) // Переход на следующий слайд
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    PageControlView(index: $index, maxIndex: viewModel.onboardingData.isEmpty ? 0 : viewModel.onboardingData.count - 1) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .CalliopeYellow()))
                            .frame(width: 35, height: 6)
                    } deselectedShape: {
                        Circle()
                            .fill(Color(uiColor: .CalliopeYellow())).opacity(0.4)
                            .frame(width: 6)
                    }
                    .offset(y: index == viewModel.onboardingData.count - 1 ? 20 : 0)
                    Spacer()
                    if index < viewModel.onboardingData.count - 1 {
                        Button(action: {
                            withAnimation {
                                self.index = viewModel.onboardingData.count - 1
                            }
                        }) {
                            Text("Пропустить")
                                .font(Font.custom("Montserrat-SemiBold", size: 18))
                                .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                .padding()
                        }
                    } else {
                        NavigationLink(destination: MainView()
                            .ignoresSafeArea(.keyboard)
                            .navigationBarBackButtonHidden(true)) {
                            HStack(spacing: 25) {
                                Text("Начнём?")
                                    .font(Font.custom("Montserrat-SemiBold", size: 18))
                                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                ZStack {
                                    Circle()
                                        .fill(Color(uiColor: .CalliopeYellow()).opacity(0.4))  // Полупрозрачный круг
                                        .frame(width: 64, height: 64)    // Размер круга
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(Color(uiColor: .CalliopeBlack()))  // Цвет стрелки
                                        .scaleEffect(x: 1.5, y: 1.5)
                                }
                            }
                            .offset(y: 20)
                            .padding()
                        }
                    }

                }
                
                Spacer()
                    .frame(height: 20)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: index) // Apply consistent animation for index changes
    }
    
    private func offset(in geometry: GeometryProxy) -> CGFloat {
        if self.dragging {
            return max(min(self.offset, 0), -CGFloat(viewModel.onboardingData.count - 1) * geometry.size.width)
        } else {
            return -CGFloat(self.index) * geometry.size.width
        }
    }
    
    private func clampedIndex(from predictedIndex: Int) -> Int {
        let newIndex = min(max(predictedIndex, self.index - 1), self.index + 1)
        
        guard newIndex >= 0 else { return 0 }
        guard newIndex <= viewModel.onboardingData.count - 1 else { return viewModel.onboardingData.count - 1 }
        
        return newIndex
    }
}
