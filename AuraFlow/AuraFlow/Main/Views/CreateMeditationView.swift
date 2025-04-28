//
//  CreateMeditationView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//


import SwiftUI
import AVKit
import Charts

struct CreateMeditationView: View {
    @StateObject private var viewModel = CreateMeditationViewModel()
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    
                    // Новое: счетчик попыток
                    Text("Попыток генерации: \(viewModel.remainingAttempts) из \(viewModel.totalAttempts)")
                        .foregroundColor(.white)
                        .font(.system(size: 18)).bold()
                        .offset( y: 10)
                        .padding(.horizontal)
                    HStack {
                        HStack {
                            Text("Время медитации: ")
                                .foregroundColor(.white)
                                .font(.system(size: 18)).bold()
                            
                            Spacer()
                            Text("\(Int(viewModel.duration)) мин.")
                                .foregroundColor(.white)
                                .font(.system(size: 18)).bold()
                                .padding(.trailing, 25)
                        }
                        .padding(.leading, 15)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.decrementDuration()
                        }) {
                            Text("-")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))
                        }
                        .contentShape(Rectangle())
                        .offset(x: -15)
                        .padding(10)
                        
                        Button(action: {
                            viewModel.incrementDuration()
                        }) {
                            Text("+")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))
                        }
                        .contentShape(Rectangle())
                        .offset(x: -20)
                        .padding(10)
                    }
                    
                    // Выбор шаблона (видео)
                    VStack(alignment: .leading) {
                        Text("Выберите шаблон")
                            .foregroundColor(.white)
                            .font(.system(size: 18)).bold()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(videosForGeneration, id: \.title) { video in
                                    VideoCell(video: video, isSelected: video.title == viewModel.selectedVideo?.title)
                                        .onTapGesture {
                                            viewModel.selectedVideo = video
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Поле ввода для описания медитации
                    VStack(alignment: .leading) {
                        Text("Какую вы бы хотели медитацию ?")
                            .foregroundColor(.white)
                            .font(.system(size: 18)).bold()
                        
                        ZStack(alignment: .leading) {
                            if viewModel.meditationPrompt.isEmpty {
                                Text("Опишите свое состояние, и то какой результат вы хотите получить от медитации.")
                                    .bold()
                                    .foregroundColor(Color(uiColor: .lightGray))
                                    .padding(.top, -40)
                            }
                            TextEditor(text: $viewModel.meditationPrompt)
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.black)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, -10)
                    
                    // Поле ввода для описания мелодии
                    VStack(alignment: .leading) {
                        Text("Какую вы бы хотели мелодию ?")
                            .foregroundColor(.white)
                            .font(.system(size: 18)).bold()
                        
                        ZStack(alignment: .leading) {
                            if viewModel.audioPrompt.isEmpty {
                                Text("Опишите, какой должна быть мелодия для вашей медитации.")
                                    .bold()
                                    .foregroundColor(Color(uiColor: .lightGray))
                                    .padding(.top, -20)
                            }
                            TextEditor(text: $viewModel.audioPrompt)
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.black)
                        .frame(height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Кнопка создания медитации
                    Button(action: {
                        viewModel.createMeditation()
                    }) {
                        Text("Создать медитацию")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                    }
                    
                    Spacer()
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .background(
                    Image("default")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
                
                // Popup при создании медитации
                if viewModel.showPopup {
                    CreatingMeditationPopupView()
                }
                
                // Навигация к плееру после создания медитации
                NavigationLink(
                    destination: Group {
                        if let selectedVideo = viewModel.selectedVideo,
                           let videoURL = URL(string: selectedVideo.videoLink),
                           let audioURL = viewModel.generatedAudioURL,
                           let meditationId = viewModel.meditationId {
                            FullScreenMeditationVideoPlayerView(
                                videoURL: videoURL,
                                audioURL: audioURL,
                                durationInMinutes: Int(viewModel.duration),
                                meditationId: meditationId
                            )
                        } else {
                            Text("Ожидание генерации...")
                        }
                    },
                    isActive: $viewModel.navigateToPlayer,
                    label: { EmptyView() }
                )
                
                if viewModel.showPopup {
                    CreatingMeditationPopupView()
                }
            }
            .alert("Нет доступных попыток !", isPresented: $viewModel.showNoAttemptsAlert) {
                Button("ОК", role: .cancel) { }
            } message: {
                Text("У вас больше нет попыток генерации. Оформите подписку или подождите обновления попыток.")
            }
            .onAppear {
                viewModel.refreshLimits()
            }            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Создай свою медитацию")
                            .font(Font.custom("Montserrat-Semibold", size: 20))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    }
                }
            
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
                    if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation(.easeOut(duration: 0.25)) {
                            keyboardHeight = frame.height
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        keyboardHeight = 0
                    }
                }
                .onAppear { viewModel.refreshLimits() }
        }
    }
}

#Preview {
    CreateMeditationView()
}

extension CreateMeditationView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
