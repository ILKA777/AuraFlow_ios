//
//  MeditationPlayerView.swift
//  Calliope
//
//  Created by Илья on 13.09.2024.
//

import SwiftUI
import AVKit

enum MediaType {
    case audio
    case video
}


struct MeditationPlayerView: View {
    @StateObject private var playbackManager = PlaybackManager.shared
    
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
    
    @State private var scrollOffset: CGFloat = 0.0
    @State private var scrollingRight: Bool = true
    @State private var timer: Timer? = nil

    
    init(meditation: Meditation, album: MeditationAlbum) {
        self.meditation = meditation
        self.album = album
        _currentMeditation = State(initialValue: meditation)  // Устанавливаем начальный трек
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
                                if isVideoPlaying {
                                    // Останавливаем видео и переключаемся на аудио
                                    isVideoPlaying = false
                                    isMediaPlaying = false
                                    currentMediaType = .audio
                                    playbackManager.seek(to: currentTime)
                                    playbackManager.togglePlayPause() // Включаем аудио воспроизведение
                                } else {
                                    dismiss() // Закрываем экран, если видео не воспроизводится
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
                            // Останавливаем текущее видео, если оно воспроизводится
                            if isVideoPlaying {
                                isVideoPlaying = false
                                isMediaPlaying = false
                                currentMediaType = .audio
                                playbackManager.stopCurrentAudio()
                            }
                            
                            // Обновляем текущий трек и перезапускаем плеер
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
                        .padding(.bottom, 40)
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
            playbackManager.isMiniPlayerVisible = false
            if currentMediaType == .audio && !playbackManager.isPlaying {
                playbackManager.togglePlayPause()
                isMediaPlaying = playbackManager.isPlaying
            }
        }
        .onDisappear {
            playbackManager.isMiniPlayerVisible = true
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
}


import SwiftUI

struct TrackListView: View {
    let album: MeditationAlbum
    let onTrackSelected: (Meditation) -> Void
    @ObservedObject private var playbackManager = PlaybackManager.shared
    @State private var selectedMeditation: Meditation? = nil  // Состояние для хранения выбранной медитации
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    dismiss()  // Закрытие треклиста
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
                
                Text(album.title)
                    .font(Font.custom("Montserrat-Semibold", size: 20))
                    .padding()
                
                Spacer()
            }
            
            List {
                ForEach(album.tracks, id: \.id) { meditation in
                    Button(action: {
                        // Запуск альбома с выбранного трека
                        onTrackSelected(meditation)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(meditation.title)
                                    .font(Font.custom("Montserrat-Semibold", size: 19))
                                    .foregroundColor(isPlayingThisMeditation(meditation) ? Color(uiColor: .CalliopeYellow()) : .white)  // Изменение цвета текущего трека
                                
                                Text(meditation.date)
                                    .font(Font.custom("Montserrat-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if isPlayingThisMeditation(meditation) {
                                Image(systemName: "play.circle.fill")
                                    .foregroundColor(Color(uiColor: .CalliopeYellow()))
                            } else {
                                Text(meditation.duration)
                                    .font(Font.custom("Montserrat-Regular", size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)  // Убираем фоновый цвет списка
            .background(Color.clear)  // Прозрачный фон
        }
        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))  // Полупрозрачный фон для стиля
    }
    
    // Проверка, играется ли текущий трек
    private func isPlayingThisMeditation(_ meditation: Meditation) -> Bool {
        playbackManager.currentMeditation?.id == meditation.id
    }
}

