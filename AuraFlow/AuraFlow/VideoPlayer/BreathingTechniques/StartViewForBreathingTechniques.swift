//
//  StartView.swift
//  Calliope
//
//  Created by Илья on 19.08.2024.
//

import SwiftUI
import AVKit

struct StartViewForBreathingTechniques: View {
    // URL видео
    let videoURL: URL
    var onPracticeCompleted: () -> Void // Замыкание для завершения практики
    
    @State private var currentPhase: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var isBreathingIn: Bool = true // Начинаем с вдоха
    @State private var cycleCount: Int = 0
    @State private var isPlaying = true
    @State private var currentTime: Double = 0.0
    @State private var videoDuration: Double = 0.0
    @State private var isUserSeeking = false
    
    let totalCycles = 6 // 6 циклов по 6 секунд (3 секунды вдох + 3 секунды выдох) = 36 секунд
    
    var body: some View {
        ZStack {
            // Видеоплеер
            VideoPlayerContainer(
                videoURL: videoURL,
                isPlaying: $isPlaying,
                currentTime: $currentTime,
                duration: $videoDuration,
                isUserSeeking: $isUserSeeking
            )
            .edgesIgnoringSafeArea(.all)
            
            // Полупрозрачный слой для затемнения фона (опционально)
            Color.gray.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if currentPhase == 0 {
                    // Изначальный текст посередине экрана
                    Text("Дыхание")
                        .font(.system(size: 46).italic().bold())
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    
                    Text("Ежедневная практика")
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    
                    Text("Давайте начнём с короткого упражнения на фокус внимания")
                        .font(.system(size: 22))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 200) // Положение текста посередине экрана
                    
                    Spacer()
                    
                    // Кнопка "Начать" внизу экрана, занимающая всю ширину с отступами 16 по бокам
                    Button(action: {
                        startBreathingExercise()
                    }) {
                        Text("Начать")
                            .font(.headline)
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(30)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                    }
                } else if currentPhase == 1 {
                    Text("Дыхание")
                        .font(.system(size: 46).italic().bold())
                        .bold()
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    
                    Text("Ежедневная практика")
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    
                    Spacer()
                    
                    // Текст "Представьте голубое небо"
                    Text("Представьте голубое небо, это\nпрекрасная метафора для размышлений")
                        .font(.system(size: 22))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                    
                    Spacer()
                } else if currentPhase == 2 {
                    // Зеленая полоса с подписью "Сделайте глубокий вдох/выдох"
                    VStack {
                        Capsule()
                            .fill(.white.opacity(0.3))
                            .frame(height: 6)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 60)
                            .overlay(
                                Capsule()
                                    .fill(.white)
                                    .frame(width: progress * (UIScreen.main.bounds.width - 120), height: 6)
                                    .animation(.linear(duration: 3.0), value: progress) // 3 секунды на заполнение/опустошение
                            )
                        
                        Text(isBreathingIn ? "Сделайте глубокий вдох" : "Сделайте глубокий выдох")
                            .font(.system(size: 22))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .padding(.top, 10)
                            .transition(.opacity)
                    }
                    
                    Spacer()
                } else if currentPhase == 3 {
                    // Текст "Поздравляем, вы завершили практику дыхания."
                    Text("Поздравляем, вы завершили практику дыхания.\nНадеемся, что вы стали чувствовать себя лучше.")
                        .font(.system(size: 22))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                    
                    Spacer()
                    
                    // Кнопка "Завершить практику" внизу экрана
                    Button(action: {
                        onPracticeCompleted() // Вызов замыкания при завершении
                    }) {
                        Text("Завершить практику")
                            .font(.headline)
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(30)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                    }
                }
            }
            
            // Кнопка "Пропустить" сверху справа
            if currentPhase != 3 { // Скрываем кнопку на последнем экране
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onPracticeCompleted() // Вызов замыкания при нажатии "Пропустить"
                        }) {
                            Text("Пропустить")
                                .font(.system(size: 18).bold())
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if currentPhase == 2 {
                startBreathingCycle()
            }
        }
    }
    
    func startBreathingExercise() {
        withAnimation {
            currentPhase = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                currentPhase = 2
            }
            startBreathingCycle()
        }
    }
    
    func startBreathingCycle() {
        if cycleCount < totalCycles {
            animateBreathing()
            cycleCount += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isBreathingIn.toggle()
                startBreathingCycle()
            }
        } else {
            withAnimation {
                currentPhase = 3
            }
        }
    }
    
    func animateBreathing() {
        progress = isBreathingIn ? 0.0 : 1.0
        withAnimation(.linear(duration: 3.0)) {
            progress = isBreathingIn ? 1.0 : 0.0
        }
    }
}
