//
//  MeditationPlayerViewForMiniPlayer.swift
//  Calliope
//
//  Created by Илья on 07.10.2024.
//


import SwiftUI
import AVKit

struct MeditationPlayerViewForMiniPlayer: View {
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
    
    func startScrolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            if scrollingRight {
                scrollOffset += 1
                if scrollOffset > UIScreen.main.bounds.width * 0.8 {
                    scrollingRight = false
                }
            } else {
                scrollOffset -= 1
                if scrollOffset < 0 {
                    scrollingRight = true
                }
            }
        }
    }

    func stopScrolling() {
        timer?.invalidate()
        timer = nil
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
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Text(currentMeditation.title)
                                    .font(Font.custom("Montserrat-Semibold", size: 34))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .padding(.horizontal, 10)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: -scrollOffset)
                            .onAppear {
                                startScrolling()
                            }
                            .onDisappear {
                                stopScrolling()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text(currentMeditation.author)
                            //.font(.subheadline)
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
            if currentMediaType == .audio && !playbackManager.isPlaying {
                playbackManager.togglePlayPause()
                isMediaPlaying = playbackManager.isPlaying
            }
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
