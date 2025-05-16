//
//  MyMeditationsView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//

//import SwiftUI
//
//struct MyMeditationsView: View {
//    @State private var selectedTab: String = "Понравившиеся" // По умолчанию
//    private let tabs = ["Понравившиеся", "Сгенерированные"]
//    @ObservedObject private var favs = FavoritesManager.shared
//    @ObservedObject private var generated = GeneratedMeditationsManager.shared
//
//
//
//    var generatedMeditationsAlbum =
//    MeditationAlbum(
//        title: "Сгенерированные",
//        author: "Сервис",
//        tracks: [],
//        status: "Альбом пополняется"
//    )
//
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Image("default")
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//                VStack(spacing: 20) {
//                    // Переключатель
//                    Picker("Выберите тип медитации", selection: $selectedTab) {
//                        ForEach(tabs, id: \.self) { tab in
//                            Text(tab).tag(tab)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding()
//                    // Spacer()
//                    // Список медитаций
//                    if selectedTab == "Понравившиеся" {
//                        MeditationListCustomView(
//                                         album: MeditationAlbum(
//                                           title: "Понравившиеся",
//                                           author: "Сервис",
//                                           tracks: favs.favorites,
//                                           status: "Альбом пополняется"
//                                         )
//                                       )
//                    } else {
//                        //MeditationListCustomView(album: generatedMeditationsAlbum)
//                        MeditationListCustomView(
//                                         album: MeditationAlbum(
//                                           title: "Сгенерированные",
//                                           author: "Сервис",
//                                           tracks: generated.generated.map { Meditation(from: $0) },
//                                           status: "Альбом пополняется"
//                                         )
//                                       )
//                    }
//                }
//                .padding(.top, 80)
//            }
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Мои медитации")
//                        .font(Font.custom("Montserrat-Semibold", size: 20))
//                        .font(.headline)
//                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}

struct MyMeditationsView: View {
    @State private var selectedTab: String = "Понравившиеся"
    @State private var searchText = ""
    private let tabs = ["Понравившиеся", "Сгенерированные"]
    @ObservedObject private var favs = FavoritesManager.shared
    @ObservedObject private var generated = GeneratedMeditationsManager.shared
    
    var body: some View {
        //NavigationStack {
            ScrollView {
                ZStack {
                    Image("default")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        
                        Text("Мои медитации")
                            .font(Font.custom("Montserrat-Semibold", size: 20))
                            .font(.headline)
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .offset(y: -10)
                        
                        // Поисковая строка
                        TextField("Поиск...", text: $searchText)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.none)
                        
                        // Переключатель
                        Picker("Выберите тип медитации", selection: $selectedTab) {
                            ForEach(tabs, id: \.self) { tab in
                                Text(tab).tag(tab)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Список медитаций
                        if selectedTab == "Понравившиеся" {
                            MeditationListCustomView(
                                album: MeditationAlbum(
                                    title: "Понравившиеся",
                                    author: "Сервис",
                                    tracks: filteredFavorites(),
                                    status: "Альбом пополняется"
                                )
                            )
                        } else {
                            MeditationListCustomView(
                                album: MeditationAlbum(
                                    title: "Сгенерированные",
                                    author: "Сервис",
                                    tracks: filteredGenerated(),
                                    status: "Альбом пополняется"
                                )
                            )
                        }
                    }
                    .padding(.top, 80)
                }
                
            }
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                    Text("Мои медитации")
//                        .font(Font.custom("Montserrat-Semibold", size: 20))
//                        .font(.headline)
//                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
//                }
//            }
            .navigationBarTitleDisplayMode(.inline)
       // }
        .edgesIgnoringSafeArea(.all)
        .scrollDisabled(true)
        
    }
    
    // Фильтрация для избранных
    private func filteredFavorites() -> [Meditation] {
        guard !searchText.isEmpty else { return favs.favorites }
        return favs.favorites.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.author.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    // Фильтрация для сгенерированных
    private func filteredGenerated() -> [Meditation] {
        let meditations = generated.generated.map { Meditation(from: $0) }
        guard !searchText.isEmpty else { return meditations }
        return meditations.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            ($0.author.localizedCaseInsensitiveContains(searchText) ?? false)
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
