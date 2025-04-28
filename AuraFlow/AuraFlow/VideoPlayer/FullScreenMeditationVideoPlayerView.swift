//
//  FullScreenMeditationVideoPlayerView.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import AVKit
import Charts

struct FullScreenMeditationVideoPlayerView: View {
    let videoURL: URL
    let audioURL : URL
    let durationInMinutes: Int // Длительность медитации, которая была выбрана пользователем
    let meditationId: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var videoPlayer = AVPlayer()
    @State private var audioPlayer = AVPlayer()
    
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var playbackManager = PlaybackManager.shared
    
    @StateObject private var heartRateReceiver = HeartRateReceiver()
    @State private var heartRateHistory: [Double] = []
    
    @State private var isPlaying = false // Состояние воспроизведения
    @State private var showControls = true // Показывать ли элементы управления
    @State private var timer: Timer? // Таймер для скрытия элементов управления
    @State private var showSaveAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CustomVideoPlayer(player: videoPlayer)
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        if playbackManager.isPlaying {
                            await playbackManager.stopCurrent()
                        }
                        
                        // Создаем композицию для видео
                        let composition = AVMutableComposition()
                        
                        let videoAsset = AVAsset(url: videoURL)
                        let videoTrack = composition.addMutableTrack(
                            withMediaType: .video,
                            preferredTrackID: kCMPersistentTrackID_Invalid
                        )
                        
                        do {
                            // Получаем исходный трек видео
                            let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first!
                            let videoDuration = videoAsset.duration
                            
                            var totalDuration: CMTime = .zero
                            let desiredDuration = CMTime(seconds: Double(durationInMinutes * 60), preferredTimescale: 600)
                            
                            // Вставляем видео несколько раз, чтобы достичь необходимой длительности
                            while totalDuration < desiredDuration {
                                let remainingDuration = desiredDuration - totalDuration
                                let timeRange = CMTimeRangeMake(start: .zero, duration: min(remainingDuration, videoDuration))
                                
                                try videoTrack?.insertTimeRange(timeRange, of: videoAssetTrack, at: totalDuration)
                                totalDuration = totalDuration + min(remainingDuration, videoDuration)
                            }
                            
                            // Настройка плеера для видео
                            let playerItem = AVPlayerItem(asset: composition)
                            videoPlayer.replaceCurrentItem(with: playerItem)
                            
                            // Настройка аудио
                            let audioItem = AVPlayerItem(url: audioURL)
                            audioPlayer.replaceCurrentItem(with: audioItem)
                            
                            togglePlayback()
                        } catch {
                            print("Error in creating video composition: \(error.localizedDescription)")
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
            
            // Управление воспроизведением
            VStack {
                Spacer()
                HStack {
                    Button(action: togglePlayback) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Button(action: rewind) {
                        Image(systemName: "gobackward.15")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Button(action: forward) {
                        Image(systemName: "goforward.15")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.bottom, 40)
            }
            .opacity(showControls ? 1 : 0) // Управление видимостью
        }
        .onTapGesture {
            // Переключение состояния показа/скрытия управления
            withAnimation {
                showControls.toggle()
            }
            resetTimer() // Перезапуск таймера
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showSaveAlert = true }) {
                    Image(systemName: "chevron.left").foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
        .alert("Хотите сохранить созданную медитацию ?", isPresented: $showSaveAlert) {
            Button("Да") {
                saveMeditation()
            }
            Button("Нет", role: .cancel) {
                dismiss()
            }
        }
    }
    
    private func saveMeditation() {
           guard let url = URL(string: NetworkService.shared.url + "user-meditations/add") else {
               dismiss(); return
           }
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           if let token = NetworkService.shared.getAuthToken(), !token.isEmpty {
               request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
           }
           let body: [String: Any] = [
               "videoUrl": audioURL.absoluteString
           ]
        print("айди \(meditationId)")
        print("videoUrl \(audioURL.absoluteString)")
           request.httpBody = try? JSONSerialization.data(withJSONObject: body)
           URLSession.shared.dataTask(with: request) { _, _, _ in
               DispatchQueue.main.async { dismiss() }
           }.resume()
       }

    
    
    // Функция для переключения play/pause
    private func togglePlayback() {
        if isPlaying {
            videoPlayer.pause()
            audioPlayer.pause()
        } else {
            videoPlayer.play()
            audioPlayer.play()
        }
        isPlaying.toggle()
    }
    
    // Функция для перемотки назад
    private func rewind() {
        let currentTime = videoPlayer.currentTime()
        let rewindTime = CMTime(seconds: 15, preferredTimescale: currentTime.timescale)
        let newTime = max(currentTime - rewindTime, .zero)
        videoPlayer.seek(to: newTime)
        audioPlayer.seek(to: newTime)
    }
    
    // Функция для перемотки вперед
    private func forward() {
        let currentTime = videoPlayer.currentTime()
        let forwardTime = CMTime(seconds: 15, preferredTimescale: currentTime.timescale)
        let newTime = currentTime + forwardTime
        videoPlayer.seek(to: newTime)
        audioPlayer.seek(to: newTime)
    }
    
    // Сброс таймера для скрытия управления
    private func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            withAnimation {
                showControls = false
            }
        }
    }
}

//#Preview {
//    let seaVideoURL = Bundle.main.url(forResource: "seaMeditation", withExtension: "mp4")?.absoluteString ?? ""
//    if let url = URL(string: seaVideoURL) {
//        FullScreenMeditationVideoPlayerView(videoURL: url, audioURL: <#URL#>, durationInMinutes: 5)
//    }
//}
// Создание кастомного видео плеера
struct CustomVideoPlayer: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(AVPlayerControllerRepresentable(player: player))
    }
}

// Представление AVPlayer для интеграции с SwiftUI
struct AVPlayerControllerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false // Скрываем стандартные элементы управления
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Можно обновить плеер, если потребуется
    }
}
