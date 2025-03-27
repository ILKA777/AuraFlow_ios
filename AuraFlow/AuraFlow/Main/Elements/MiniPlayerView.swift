//
//  MiniPlayerView.swift
//  Calliope
//
//  Created by Илья on 22.08.2024.
//

import SwiftUI
import AVKit

struct MiniPlayerView: View {
    @ObservedObject var playbackManager: PlaybackManager
    @State private var isMeditationPlayerPresented = false

    var body: some View {
        ZStack {
            BlurView(style: .systemThinMaterial)
            VStack {
                if let meditation = playbackManager.currentMeditation {
                    HStack(alignment: .center, spacing: 10) {
                        Image(uiImage: meditation.image)
                            .resizable()
                            .frame(width: 53, height: 53)
                            .cornerRadius(8)
                            .offset(y: -8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Marquee(text: meditation.title, font: UIFont(name: "Montserrat-Semibold", size: 15) ?? .systemFont(ofSize: 15))
                                .offset(x: -15)
                            
                            Text(meditation.author)
                                .font(Font.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(1)

                            HStack {
                                Text(playbackManager.currentTimeString)
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text(playbackManager.remainingTimeString)
                                    .font(.caption)
                            }
                            
                            UISliderView(
                                value: Binding(
                                    get: { playbackManager.currentTime },
                                    set: { newValue in
                                        playbackManager.seek(to: newValue)
                                        //playbackManager.seekKinescope(to: newValue)
                                    }
                                ),
                                minValue: 0.0,
                                maxValue: playbackManager.duration,
                                thumbColor: .clear,
                                minTrackColor: .AuraFlowBlue(),
                                maxTrackColor: .lightGray
                            )
                            .frame(height: 20)
                            .padding(.top, -5)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            playbackManager.togglePlayPause()
                        }) {
                            Image(systemName: playbackManager.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        }
                        .offset(y: -20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                } else {
                    EmptyView()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(maxHeight: 150)
        .cornerRadius(12)
        .padding(.horizontal)
        .onTapGesture {
            if playbackManager.currentMeditation != nil {
                            isMeditationPlayerPresented = true
                        }
        }
        .fullScreenCover(isPresented: $isMeditationPlayerPresented) {
            if let meditation = playbackManager.currentMeditation {
                let tempAlbum = MeditationAlbum(
                    title: "Текущая медитация",
                    author: "Сервис",
                    tracks: [meditation],
                    status: "Пополняется"
                )
                MeditationPlayerViewForMiniPlayer(meditation: meditation, album: tempAlbum)
                    .onDisappear {
                        playbackManager.isMiniPlayerVisible = true
                    }
            }
        }
    }
}

#Preview {
    MiniPlayerView(playbackManager: MockPlaybackManager())
        .previewLayout(.sizeThatFits)
}

// Mock PlaybackManager for Preview
class MockPlaybackManager: PlaybackManager {
    override init() {
        super.init()
        self.currentMeditation = Meditation(
            title: "Медитация для настройки",
            author: "Тестовый автор",
            date: "22 августа 2024",
            duration: "10 мин",
            videoLink: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            image: UIImage(named: "meditation1")!,
            tags: ["Тест", "Настройка"]
        )
        self.isPlaying = true
        self.currentTime = 60.0
        self.duration = 300.0
    }
}
