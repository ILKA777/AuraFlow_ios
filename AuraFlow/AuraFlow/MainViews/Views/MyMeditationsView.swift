//
//  MyMeditationsView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//

import SwiftUI

struct MyMeditationsView: View {
    @State private var selectedTab: String = "Понравившиеся" // По умолчанию
    private let tabs = ["Понравившиеся", "Сгенерированные"]
    
    var favoriteMeditationsAlbum =
    MeditationAlbum(
        title: "Понравившееся",
        author: "Сервис",
        tracks: sampleMeditations.filter { $0.tags.contains("Отдых") },
        status: "Альбом пополняется"
    )
    
    var generatedMeditationsAlbum =
    MeditationAlbum(
        title: "Сгенерированные",
        author: "Сервис",
        tracks: sampleMeditations.filter { $0.tags.contains("Работа") },
        status: "Альбом пополняется"
    )
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("default")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    // Переключатель
                    Picker("Выберите тип медитации", selection: $selectedTab) {
                        ForEach(tabs, id: \.self) { tab in
                            Text(tab).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    // Spacer()
                    // Список медитаций
                    if selectedTab == "Понравившиеся" {
                        MeditationListCustomView(album:favoriteMeditationsAlbum)
                    } else {
                        MeditationListCustomView(album: generatedMeditationsAlbum)
                    }
                }
                .padding(.top, 80)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Мои медитации")
                        .font(Font.custom("Montserrat-Semibold", size: 20))
                        .font(.headline)
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

import SwiftUI

struct MeditationListCustomView: View {
    let album: MeditationAlbum
    @ObservedObject private var playbackManager = PlaybackManager.shared
    
    // Состояние для управления переходом
    @State private var selectedMeditation: Meditation? = nil
    
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
        List {
            ForEach(album.tracks, id: \.id) { meditation in
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
        .frame(maxHeight: .infinity)
    }
    private func isPlayingThisMeditation(_ meditation: Meditation) -> Bool {
        playbackManager.currentMeditation?.id == meditation.id
    }
}
