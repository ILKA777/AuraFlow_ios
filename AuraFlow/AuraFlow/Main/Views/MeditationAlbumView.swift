//
//  MeditationAlbumView.swift
//  Calliope
//
//  Created by Илья on 13.08.2024.
//

import SwiftUI

struct MeditationAlbumView: View {
    let album: MeditationAlbum
    let width: CGFloat
    let height: CGFloat
    
    @ObservedObject private var playbackManager = PlaybackManager.shared
    @State private var isPlaying: Bool = false
    
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationLink(destination: MeditationListView(album: album, navigationPath: $navigationPath)) {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(isPlaying ? Color(uiColor: .AuraFlowBlue()) : Color.gray.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(album.title)
                        .font(Font.custom("Montserrat-SemiBold", size: 23))
                        .foregroundColor(isPlaying ? Color(uiColor: .CalliopeBlack()) : Color(uiColor: .CalliopeWhite()))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("От \(album.author)")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(isPlaying ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                    
                    Spacer()
                    
                    HStack {
                        Text("\(album.trackCount) треков")
                            .font(Font.custom("Montserrat-Regular", size: 15.11))
                            .foregroundColor(isPlaying ? Color(uiColor: .CalliopeBlack()).opacity(0.7) : Color(uiColor: .CalliopeWhite()).opacity(0.7))
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.gray.opacity(isPlaying ? 0 : 0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(isPlaying ? Color(uiColor: .CalliopeBlack()) : Color.clear, lineWidth: 1.5)
                            )
                            .cornerRadius(17)
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                if isPlaying {
                                    await playbackManager.stopCurrent()
                                } else {
                                    await playbackManager.playAlbum(album: album)
                                }
                                updatePlayingState()
                            }
                        }) {
                            ZStack {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(isPlaying ? Color(uiColor: .CalliopeBlack()) : Color(uiColor: .AuraFlowBlue()))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .offset(y: -10)
                }
                .padding()
            }
            .frame(width: width, height: height)
            .padding(.horizontal)
            .onAppear {
                updatePlayingState()
            }
            .onReceive(playbackManager.$currentAlbum) { _ in
                updatePlayingState()
            }
            .onReceive(playbackManager.$isPlaying) { _ in
                updatePlayingState()
            }
            .animation(.easeInOut, value: isPlaying)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isPlayingThisAlbum: Bool {
        return playbackManager.currentAlbum?.id == album.id && playbackManager.isPlaying
    }
    
    private func updatePlayingState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isPlaying = isPlayingThisAlbum
        }
    }
}
