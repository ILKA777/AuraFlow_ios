//
//  MeditationView.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI
import AVKit

struct MeditationView: View {
    let meditation: Meditation
    
    @ObservedObject private var playbackManager = PlaybackManager.shared
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .AuraFlowBlue()) : Color.gray.opacity(0.3))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(meditation.title)
                    .font(Font.custom("Montserrat-Semibold", size: 18))
                    .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()) : Color(uiColor: .CalliopeWhite()))
                
                HStack {
                    Text("От \(meditation.author)")
                        .font(Font.custom("Montserrat-Regular", size: 14))
                        .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                    
                    Text("·")
                        .font(Font.custom("Montserrat-Semibold", size: 14))
                        .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        .scaleEffect(x: 2.0, y: 2.0)
                    
                    Text(meditation.albumStatus)
                        .font(Font.custom("Montserrat-Regular", size: 14))
                        .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                }
                
                HStack {
                    Text(meditation.duration)
                        .font(.system(size: 14))
                        .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(playbackManager.isPlaying && isPlayingThisMeditation ? Color.gray.opacity(0.3) : Color.gray.opacity(0.3))
                        .cornerRadius(17)
                    
                    HStack(spacing: 5) {
                        ForEach(meditation.tags, id: \.self) { tag in
                            Text(tag)
                                .font(Font.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .frame(height: 30)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 17)
                                        .stroke(playbackManager.isPlaying && isPlayingThisMeditation ? Color.gray.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(17)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .layoutPriority(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    
                    Button(action: {
                        Task {
                            if isPlayingThisMeditation {
                                await playbackManager.stopCurrent()
                            } else {
                                let album = MeditationAlbum(
                                    title: meditation.title,
                                    author: meditation.author,
                                    tracks: [meditation], status: meditation.albumStatus
                                )
                                await playbackManager.playAlbum(album: album)
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.7))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: playbackManager.isPlaying && isPlayingThisMeditation ? "pause.fill" : "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(playbackManager.isPlaying && isPlayingThisMeditation ? Color(uiColor: .CalliopeBlack()) : Color(uiColor: .AuraFlowBlue()))
                        }
                    }
                }
            }
            .padding()
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .animation(.easeInOut, value: playbackManager.isPlaying)
    }
    
    private var isPlayingThisMeditation: Bool {
        return playbackManager.currentMeditation?.id == meditation.id
    }
}

#Preview {
    MeditationView(meditation: sampleMeditations[0])
}
