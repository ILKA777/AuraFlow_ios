//
//  MeditationListView.swift
//  Calliope
//
//  Created by Илья on 23.08.2024.
//

import SwiftUI

struct MeditationListView: View {
    let album: MeditationAlbum
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var playbackManager = PlaybackManager.shared
    @State private var searchText: String = ""
    @FocusState private var isSearching: Bool
    @FocusState private var isInputActive: Bool
    
    // Состояние для управления переходом
    @State private var selectedMeditation: Meditation? = nil
    
    @Binding var navigationPath: NavigationPath
    
    @State private var scrollOffset: CGFloat = 0.0
    @State private var scrollingRight: Bool = true
    @State private var timer: Timer? = nil
    
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
            if let firstMeditation = album.tracks.first {
                Image(uiImage: firstMeditation.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
                    .overlay(Color(uiColor: .CalliopeBlack()).opacity(0.4))
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.7))
                                .frame(width: 48, height: 48)
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        }
                    }
                    .padding(.leading, 16)
                    
                    ZStack {
                        if !isSearching {
                            Text(album.title)
                                .font(Font.custom("Montserrat-Semibold", size: 24))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding(.leading, 16)
                                .padding(.trailing, 16 + 20 + 48)
                                .transition(.opacity)
                                .animation(.easeInOut, value: isSearching)
                        }
                        
                        // Поисковая строка всегда на переднем плане
                        CustomSearchbar(searchText: $searchText)
                            .padding(.trailing, 16)
                            .focused($isSearching)
                            .onTapGesture {
                                withAnimation {
                                    isSearching = true
                                }
                            }
                            .padding(.trailing, -20)
                    }
                }
                .ignoresSafeArea(.keyboard)
                
                if !isSearching {
                    VStack(spacing: 5) {
                        Text("\(album.author) • \(album.status)")
                            .font(Font.custom("Montserrat-Regular", size: 14))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 260)
                    .animation(.easeInOut, value: isSearching)
                }
                
                if !isSearching {
                    HStack(spacing: 20) {
                        Button(action: {
                            // Add action for Like button here
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.7))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            }
                        }
                        
                        Button(action: {
                            Task {  // Создаем асинхронную задачу
                                if playbackManager.isPlaying {
                                    await playbackManager.stopCurrent()
                                } else {
                                    await playbackManager.playAlbum(album: album)  // Используем await для асинхронного вызова
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.7))
                                    .frame(width: 64, height: 64)
                                
                                Image(systemName: playbackManager.isPlaying ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(playbackManager.isPlaying ? Color(uiColor: .CalliopeBlack()) : Color(uiColor: .CalliopeWhite()))
                            }
                        }
                        
                        Button(action: {
                            // Add action for Share button here
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.7))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                Spacer()
                
                // Meditation List
                List {
                    ForEach(filteredMeditations, id: \.id) { meditation in
                        Button(action: {
                            
                            selectedMeditation = meditation
                            Task {
                                // Запуск альбома с выбранного трека и переход к MeditationPlayerView
                                await playbackManager.playAlbum(from: album, startingAt: meditation)
                                  // Инициируем переход
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meditation.title)
                                        .font(Font.custom("Montserrat-Semibold", size: 19))
                                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                        .lineLimit(1)
                                    Text(meditation.date)
                                        .font(Font.custom("Montserrat-Regular", size: 14))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if isPlayingThisMeditation(meditation) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(Color(uiColor: .AuraFlowBlue()))
                                } else {
                                    Text(meditation.duration)
                                        .font(Font.custom("Montserrat-Regular", size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                            .background(Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, 16)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.top, isSearching ? 20 : -40)
                .frame(maxHeight: .infinity)
            }
            .padding(.top, 0)
            .background(Color.clear)
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if playbackManager.currentAlbum?.id == album.id {
                playbackManager.observeCurrentItem()
            }
        }
        
        .background(
            EmptyView()
                .fullScreenCover(item: $selectedMeditation) { meditation in
                    MeditationPlayerView(meditation: meditation, album: album)
                }
        )

    }
    
    private var filteredMeditations: [Meditation] {
        if searchText.isEmpty {
            return album.tracks
        } else {
            return album.tracks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func isPlayingThisMeditation(_ meditation: Meditation) -> Bool {
        playbackManager.currentMeditation?.id == meditation.id
    }
}



