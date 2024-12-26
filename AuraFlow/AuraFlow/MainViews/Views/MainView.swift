//
//  MainView.swift
//  Calliope
//
//  Created by Илья on 07.08.2024.
//


import SwiftUI

struct MainView: View {
    @FocusState private var isInputActive: Bool
    @State private var searchText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var shouldShowBreathingPractice = false
    
    @StateObject private var playbackManager = PlaybackManager.shared
    
    @State private var navigationPath = NavigationPath()
    
    let tags = ["Природа", "Звуки", "Релакс", "Гармония", "Работа", "Личный рост"]
    let skyMeditationURL = Bundle.main.url(forResource: "skyMeditation", withExtension: "mp4")?.absoluteString ?? ""
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                if shouldShowBreathingPractice {
                    StartView(
                        videoURL: URL(string: skyMeditationURL)!,
                        onPracticeCompleted: {
                            shouldShowBreathingPractice = false
                        }
                    )
                } else {
                    NavigationStack {
                        ZStack {
                            Image("default")
                                .resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                            
                            VStack {
                                VStack(spacing: 10) {
                                    HStack {
                                        MainSearchBar(searchText: $searchText)
                                            .frame(maxWidth: .infinity)
                                            .padding(.leading, -8)
                                            .offset(x: 10)
                                            .focused($isInputActive)
                                        
                                        Spacer()
                                        if isInputActive || searchText != "" {
                                            HStack {
                                                Button(action: {
                                                    // Сброс поиска и закрытие клавиатуры
                                                    searchText = ""
                                                    isInputActive = false
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(uiColor: .CalliopeDarkGreen()))
                                                            .frame(width: 48, height: 48)
                                                        
                                                        Image(systemName: "xmark")
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                    }
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 50)
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                                    
                                                    .padding(.trailing, 16)
                                                }
                                                if isInputActive {
                                                    Circle()
                                                        .fill(.clear)
                                                        .frame(width: 40, height: 40)
                                                }
                                                
                                            }
                                        } else {
                                            HStack {
                                                NavigationLink(destination: ProfileView()) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(uiColor: .CalliopeYellow()))
                                                            .frame(width: 48, height: 48)
                                                        
                                                        Image(systemName: "person")
                                                            .resizable()
                                                            .frame(width: 24, height: 24)
                                                            .foregroundColor(Color(uiColor: .CalliopeBlack()))
                                                    }
                                                    
                                                   .padding(.trailing, 16)
                                                }
                                            }
                                            
                                        }
                                    }
                                    .padding(.top, UIScreen.main.bounds.height == 667 ? 100 : 40)
                                    .padding(.bottom, 20)
                                    
                                    if isInputActive {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(tags, id: \.self) { tag in
                                                    Button(action: {
                                                        DispatchQueue.main.async {
                                                            searchText = tag
                                                            isInputActive = true
                                                        }
                                                    }) {
                                                        Text(tag)
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 6)
                                                            .background(Color(uiColor: .CalliopeYellow()).opacity(0.2))
                                                            .cornerRadius(20)
                                                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                            .font(Font.custom("Montserrat-Regular", size: 16))
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                        .transition(.move(edge: .top).combined(with: .opacity))
                                        .animation(.easeInOut(duration: 0.3), value: isInputActive)
                                        .padding(.trailing, 48)
                                    }
                                }
                                
                                if searchText.isEmpty && !isInputActive {
                                    ScrollView(showsIndicators: false) {
                                        VStack {
                                            HStack {
                                                Text("Специально для вас")
                                                    .font(Font.custom("Montserrat-Regular", size: 26))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                
                                                Spacer()
                                                
                                                NavigationLink(destination: AllAlbumsView(navigationPath: $navigationPath)) {
                                                    Text("Все")
                                                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                        .bold()
                                                }
                                                .padding(.trailing, 10)
                                            }
                                            .padding(.horizontal)
                                            .padding(.top, 20)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: -10) {
                                                    ForEach(sampleAlbums) { album in
                                                        MeditationAlbumView(album: album, width: UIScreen.main.bounds.width * 0.51, height: 210, navigationPath: $navigationPath)
                                                    }
                                                }
                                            }
                                            
                                            HStack {
                                                Text("Рекомендации")
                                                    .font(Font.custom("Montserrat-Regular", size: 26))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                
                                                Spacer()
                                                
                                                NavigationLink(destination: AllMeditationsView()) {
                                                    Text("Все")
                                                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                        .bold()
                                                }
                                                .padding(.trailing, 10)
                                            }
                                            .padding(.horizontal)
                                            .padding(.top, 20)
                                            
                                            VStack(spacing: 40) {
                                                ForEach(sampleMeditations) { meditation in
                                                    MeditationView(meditation: meditation)
                                                }
                                            }
                                            .padding(.top, 10)
                                            .padding(.bottom, playbackManager.isMiniPlayerVisible ? (UIScreen.main.bounds.height == 667 ? 220 : 160) : (UIScreen.main.bounds.height == 667 ? 120 : 60)) // Динамическое изменение нижнего отступа
                                        }
                                    }
                                    .padding(.top, -20)
                                    .padding(.bottom, keyboardHeight)
                                } else {
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 60) {
                                            if !filteredAlbums.isEmpty {
                                                Text("Альбомы")
                                                    .font(Font.custom("Montserrat-Regular", size: 24))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                    .padding(.leading, 16)
                                                    .padding(.top, 20)
                                                    .padding(.bottom, -20)
                                                
                                                ForEach(filteredAlbums) { album in
                                                    MeditationAlbumView(album: album, width: UIScreen.main.bounds.width - 40, height: 100, navigationPath: $navigationPath)
                                                }
                                            }
                                            
                                            if !filteredMeditations.isEmpty {
                                                Text("Медитации")
                                                    .font(Font.custom("Montserrat-Regular", size: 24))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                    .padding(.leading, 16)
                                                
                                                ForEach(filteredMeditations) { meditation in
                                                    MeditationListItemView(meditation: meditation, isInputActive: isInputActive) {
                                                        // Создаем временный альбом с одной медитацией
                                                        let tempAlbum = MeditationAlbum(
                                                            title: "Текущая медитация",
                                                            author: "Сервис",
                                                            tracks: [meditation],
                                                            status: "Пополняется"
                                                        )
                                                        
                                                        Task {
                                                            await playbackManager.playAlbum(album: tempAlbum)
                                                        }
                                                    }
                                                }
                                                .padding(.top, -40)
                                                
                                            }
                                        }
                                    }
                                    
                                    .padding(.top, 10)
                                    .padding(.bottom, isInputActive ? keyboardHeight + 120 : (playbackManager.isMiniPlayerVisible ? keyboardHeight + 150 : keyboardHeight + 40))
                                }
                            }
                            .navigationBarHidden(true)
                            .onTapGesture {
                                isInputActive = false
                            }
                        }
                        .offset(y: UIScreen.main.bounds.height == 667 ? keyboardHeight / 2.25 : keyboardHeight / 2.30)
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                                withAnimation {
                                    keyboardHeight = keyboardFrame.height
                                }
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                            withAnimation {
                                keyboardHeight = 0
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .ignoresSafeArea(.keyboard, edges: .all)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    if playbackManager.isMiniPlayerVisible && playbackManager.currentMeditation != nil {
                        MiniPlayerView(playbackManager: playbackManager)
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                            .animation(.easeInOut)
                            .frame(width: UIScreen.main.bounds.width)
                            .padding(.bottom, -15)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                //.padding(.bottom, 0)
            }
        }
        .onAppear {
            shouldShowBreathingPractice = UserDefaults.standard.bool(forKey: "launchWithBreathingPractice")
        }
    }
    
    var filteredAlbums: [MeditationAlbum] {
        if searchText.isEmpty {
            return []
        } else {
            return sampleAlbums.filter { album in
                let searchLowercased = searchText.lowercased()
                return album.title.lowercased().contains(searchLowercased) ||
                album.author.lowercased().contains(searchLowercased) // Проверка на автора альбома
            }
        }
    }
    
    var filteredMeditations: [Meditation] {
        if searchText.isEmpty {
            return []
        } else {
            return sampleMeditations.filter { meditation in
                let searchLowercased = searchText.lowercased()
                return meditation.title.lowercased().contains(searchLowercased) ||
                meditation.author.lowercased().contains(searchLowercased) // Проверка на автора медитации
            }
        }
    }
}

#Preview {
    MainView()
}
