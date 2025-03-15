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
    @State private var selectedDuration = 5
    @State private var melodyPrompt = ""
    @State private var meditationPrompt = ""
    @State private var audioPrompt = ""
    @State private var selectedVideo: VideoForGeneration? = nil
    
    let durations = [5, 10, 15, 20, 30, 45, 60]  // Available meditation durations
    @State private var duration: Double = 5
    
    @State private var showPopup: Bool = false
    @State private var navigateToPlayer: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    // Title and Duration Controls
                    HStack {
                        HStack {
                            Text("Время медитации: ")
                                .foregroundColor(.white)
                                .font(.system(size: 18)).bold()
                            
                            Spacer()
                            Text("\(Int(duration)) мин.")
                                .foregroundColor(.white)
                                .font(.system(size: 18)).bold()
                                .padding(.trailing, 25)
                        }
                        .padding(.leading, 15)
                        
                        Spacer()
                        
                        Button(action: {
                            if duration > 0 {
                                duration -= 1
                            }
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
                            if duration < 30 {
                                duration += 1
                            }
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
                    // .padding(.top, 30)
                    
                    
                    // Melody Prompt Field
                    VStack(alignment: .leading) {
                        Text("Выберите шаблон")
                            .foregroundColor(.white)
                            .font(.system(size: 18)).bold()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(videosForGeneration, id: \.title) { video in
                                    VideoCell(video: video, isSelected: video.title == selectedVideo?.title)
                                        .onTapGesture {
                                            selectedVideo = video
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                    // .padding(.top, 10)
                    
                    // Meditation Prompt Field
                    VStack(alignment: .leading) {
                        Text("Какую вы бы хотели медитацию ?")
                            .foregroundColor(.white)
                            .font(.system(size: 18)).bold()
                        
                        ZStack(alignment: .leading) {
                            if meditationPrompt.isEmpty {
                                Text("Опишите свое состояние, и то какой результат вы хотите получить от медитации.")
                                    .bold()
                                    .foregroundColor(Color(uiColor: .lightGray))
                                    .padding(.top, -40)
                            }
                            TextEditor(text: $meditationPrompt)
                                .onTapGesture {
                                    hideKeyboard()
                                }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.black)
                        .frame(height: 130)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, -10)
                    
                    VStack(alignment: .leading) {
                        Text("Какую вы бы хотели мелодию ?")
                            .foregroundColor(.white)
                            .font(.system(size: 18)).bold()
                        
                        ZStack(alignment: .leading) {
                            if audioPrompt.isEmpty {
                                Text("Опишите, какой должна быть мелодия для вашей медитации.")
                                    .bold()
                                    .foregroundColor(Color(uiColor: .lightGray))
                                    .padding(.top, -20)
                            }
                            TextEditor(text: $audioPrompt)
                                .onTapGesture {
                                    hideKeyboard()
                                }
                            
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .scrollContentBackground(.hidden)
                        .foregroundColor(.black)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    //.padding(.top, 10)
                    
                    // Create Meditation Button
                    Button(action: {
                        // По тапу показываем popup и запускаем таймер 10 сек
                        showPopup = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showPopup = false
                            navigateToPlayer = true
                        }
                        print("Создание медитации с длительностью: \(selectedDuration) минут, промптом для мелодии: \(melodyPrompt), промптом для медитации: \(meditationPrompt)")
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
                
                // Popup Overlay
                if showPopup {
                    CreatingMeditationPopupView()
                }
                
                // Навигация к видео плееру после завершения "загрузки"
                NavigationLink(
                    destination: Group {
                        if let selectedVideo = selectedVideo, let url = URL(string: selectedVideo.videoLink) {
                            FullScreenMeditationVideoPlayerView(videoURL: url)
                        } else {
                            Text("Видео не выбрано")
                        }
                    },
                    isActive: $navigateToPlayer,
                    label: { EmptyView() }
                )
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Создай свою медитацию")
                        .font(Font.custom("Montserrat-Semibold", size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
    }
}

extension CreateMeditationView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CreatingMeditationPopupView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2.0)
            Text("Создаю медитацию ✨")
                .font(.title2)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

import SwiftUI
import AVKit
import Charts

struct FullScreenMeditationVideoPlayerView: View {
    let videoURL: URL
    let audioURL = URL(string: "https://storage.googleapis.com/auraflow_bucket/audio/meditation_20250310_144922_1ae4b501.mp3")!
    
    @Environment(\.dismiss) private var dismiss
    @State private var videoPlayer = AVPlayer()
    @State private var audioPlayer = AVPlayer()
    
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var playbackManager = PlaybackManager.shared
    
    @StateObject private var heartRateReceiver = HeartRateReceiver()
    @State private var heartRateHistory: [Double] = []
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VideoPlayer(player: videoPlayer)
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        if playbackManager.isPlaying {
                            await playbackManager.stopCurrent()
                        }
                        
                        let videoItem = AVPlayerItem(url: videoURL)
                        videoPlayer.replaceCurrentItem(with: videoItem)
                        videoPlayer.play()
                        
                        let audioItem = AVPlayerItem(url: audioURL)
                        audioPlayer.replaceCurrentItem(with: audioItem)
                        audioPlayer.play()
                    }
                    
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                        let currentHR = heartRateReceiver.heartRate
                        heartRateHistory.append(currentHR)
                        if heartRateHistory.count > 20 {
                            heartRateHistory.removeFirst()
                        }
                    }
                }
                .onDisappear {
                    videoPlayer.pause()
                    videoPlayer.replaceCurrentItem(with: nil)
                    
                    audioPlayer.pause()
                    audioPlayer.replaceCurrentItem(with: nil)
                }
            
            if healthKitManager.showPulseDuringVideo {
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Пульс")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 4)
                            
                            Text("\(Int(heartRateReceiver.heartRate)) BPM")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 5)
                            
                            Chart {
                                ForEach(heartRateHistory.indices, id: \..self) { index in
                                    LineMark(
                                        x: .value("Time", index),
                                        y: .value("Heart Rate", heartRateHistory[index])
                                    )
                                    .interpolationMethod(.monotone)
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [.red, .orange]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic)
                            }
                            .chartXScale(domain: 0...max(Double(heartRateHistory.count) + 30, 30))
                            .frame(width: 150, height: 100)
                            .padding(.horizontal, 10)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
    }
}



#Preview {
    CreateMeditationView()
}
