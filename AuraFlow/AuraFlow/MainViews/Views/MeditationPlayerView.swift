//
//  MeditationPlayerView.swift
//  Calliope
//
//  Created by Илья on 13.09.2024.
//

import SwiftUI
import AVKit
import Charts

enum MediaType {
    case audio
    case video
}

struct MeditationPlayerView: View {
    @StateObject private var playbackManager = PlaybackManager.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var heartRateReceiver = HeartRateReceiver()
    
    let meditation: Meditation
    let album: MeditationAlbum
    @Environment(\.dismiss) private var dismiss
    
    @State private var isVideoPlaying = false
    @State private var currentMediaType: MediaType = .audio
    @State private var isMediaPlaying: Bool = false
    @State private var currentTime: Double = 0.0
    @State private var mediaDuration: Double = 1.0
    @State private var isUserSeeking = false
    @State private var showTrackList = false
    @State private var currentMeditation: Meditation
    
    @State private var areControlsVisible = true
    
    @State private var heartRateHistory: [Double] = []
    // Новые состояния для итогов медитации
    @State private var startHeartRate: Double = 0
    @State private var endHeartRate: Double = 0
    @State private var showSummary: Bool = false
    
    // Новое состояние для отслеживания времени входа
    @State private var viewAppearTime: Date? = nil

    init(meditation: Meditation, album: MeditationAlbum) {
        self.meditation = meditation
        self.album = album
        _currentMeditation = State(initialValue: meditation)
    }
    
    var body: some View {
        ZStack {
            if isVideoPlaying {
                VideoPlayerContainer(
                    videoURL: URL(string: currentMeditation.videoLink)!,
                    isPlaying: $isMediaPlaying,
                    currentTime: $currentTime,
                    duration: $mediaDuration,
                    isUserSeeking: $isUserSeeking
                )
                .onDisappear {
                    if currentMediaType == .video {
                        isVideoPlaying = false
                        isMediaPlaying = false
                        currentMediaType = .audio
                        playbackManager.seek(to: currentTime)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        areControlsVisible.toggle()
                    }
                }
                .onAppear {
                    playbackManager.stopCurrentAudio()
                }
                // В правом верхнем углу отображаем пульс и график
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
                                    ForEach(heartRateHistory.indices, id: \.self) { index in
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
                                .chartXScale(domain: 0...heartRateHistory.count + 30)
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
            } else {
                Image(uiImage: currentMeditation.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .blur(radius: 10)
                    .ignoresSafeArea()
            }
            
            if areControlsVisible {
                VStack {
                    HStack {
                        Button(action: {
                            // Если видео активно, останавливаем его
                            if isVideoPlaying {
                                isVideoPlaying = false
                                isMediaPlaying = false
                                currentMediaType = .audio
                                playbackManager.seek(to: currentTime)
                                playbackManager.togglePlayPause()
                            }
                            // Проверяем время пребывания на экране
                            if let appearTime = viewAppearTime,
                               Date().timeIntervalSince(appearTime) > 60, healthKitManager.showPulseAnalyticsAfterExit {
                                finishMeditation()
                            } else {
                                dismiss()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        Button(action: {
                            showTrackList.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 30)
                    .fullScreenCover(isPresented: $showTrackList) {
                        TrackListView(album: album, onTrackSelected: { selectedTrack in
                            if isVideoPlaying {
                                isVideoPlaying = false
                                isMediaPlaying = false
                                currentMediaType = .audio
                                playbackManager.stopCurrentAudio()
                            }
                            currentMeditation = selectedTrack
                            Task {
                                await playbackManager.playAlbum(from: album, startingAt: selectedTrack)
                                playbackManager.isMiniPlayerVisible = false
                            }
                        })
                    }
                    
                    Spacer()
                    
                    if !isVideoPlaying {
                        ZStack {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.width * 0.85)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 15)
                                )
                            
                            Image(uiImage: currentMeditation.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width * 0.82, height: UIScreen.main.bounds.width * 0.82)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                .onTapGesture {
                                    withAnimation {
                                        currentTime = playbackManager.currentTime
                                        mediaDuration = playbackManager.duration
                                        playbackManager.stopCurrentAudio()
                                        currentMediaType = .video
                                        isMediaPlaying = true
                                        isVideoPlaying = true
                                    }
                                }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Marquee(text: currentMeditation.title, font: UIFont(name: "Montserrat-Semibold", size: 34) ?? .systemFont(ofSize: 34))
                        
                        Text(currentMeditation.author)
                            .font(Font.custom("Montserrat-Regular", size: 16))
                            .foregroundColor(.gray)
                        
                        Slider(value: Binding(
                            get: { currentTime },
                            set: { newValue in
                                isUserSeeking = true
                                currentTime = newValue
                                if currentMediaType == .audio {
                                    playbackManager.seek(to: newValue)
                                    isUserSeeking = false
                                }
                            }
                        ), in: 0...mediaDuration)
                        .accentColor(.white)
                        .padding(.horizontal, 16)
                        
                        HStack {
                            Text("\(formatTime(currentTime))")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(formatTime(mediaDuration - currentTime))")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                rewind(by: 30)
                            }) {
                                Image(systemName: "gobackward.30")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                if currentMediaType == .audio {
                                    playbackManager.togglePlayPause()
                                } else {
                                    isMediaPlaying.toggle()
                                }
                            })  {
                                Image(systemName: (playbackManager.isPlaying || isMediaPlaying) ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                forward(by: 30)
                            }) {
                                Image(systemName: "goforward.30")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 20)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: areControlsVisible)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewAppearTime = Date()  // Записываем время входа на экран
            playbackManager.isMiniPlayerVisible = false
            // Сохраняем начальное значение пульса при запуске медитации
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                startHeartRate = heartRateReceiver.heartRate
            }
            
            if currentMediaType == .audio && !playbackManager.isPlaying {
                playbackManager.togglePlayPause()
                isMediaPlaying = playbackManager.isPlaying
            }
            
            // Обновляем историю пульса каждые 2 секунды
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                let heartRate = heartRateReceiver.heartRate
                heartRateHistory.append(heartRate)
                if heartRateHistory.count > 20 {
                    heartRateHistory.removeFirst()
                }
            }
        }
        .onDisappear {
            playbackManager.isMiniPlayerVisible = true
        }
        // Sheet с итогами медитации; при закрытии итогового окна происходит dismiss() плеера
        .sheet(isPresented: $showSummary, onDismiss: {
            dismiss()
        }) {
            MeditationSummaryView(startHeartRate: startHeartRate, endHeartRate: endHeartRate, heartRateHistory: heartRateHistory)
        }
        .onReceive(playbackManager.$currentTime) { newTime in
            if currentMediaType == .audio && !isUserSeeking {
                currentTime = newTime
            }
        }
        .onReceive(playbackManager.$duration) { newDuration in
            if currentMediaType == .audio {
                mediaDuration = newDuration
            }
        }
    }
    
    private func rewind(by seconds: Double) {
        let newTime = max(currentTime - seconds, 0)
        currentTime = newTime
        if currentMediaType == .audio {
            playbackManager.seek(to: newTime)
        }
        isUserSeeking = true
    }
    
    private func forward(by seconds: Double) {
        let newTime = min(currentTime + seconds, mediaDuration)
        currentTime = newTime
        if currentMediaType == .audio {
            playbackManager.seek(to: newTime)
        }
        isUserSeeking = true
    }
    
    func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
    
    // Функция завершения медитации: сохраняет конечный пульс и показывает экран с итогами
    private func finishMeditation() {
        endHeartRate = heartRateReceiver.heartRate
        showSummary = true
    }
}
