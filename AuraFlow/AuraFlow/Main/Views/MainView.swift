//
//  MainView.swift
//  Calliope
//
//  Created by Илья on 07.08.2024.
//


import SwiftUI

struct MainView: View {
    @Binding var selectedTab: TabBarView.Tab
    @FocusState private var isInputActive: Bool
    
    // Используем ViewModel для управления состоянием
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var playbackManager = PlaybackManager.shared
    
    let tags = ["Природа", "Звуки", "Релакс", "Гармония", "Работа", "Личный рост"]
    let skyMeditationURL = Bundle.main.url(forResource: "skyMeditation", withExtension: "mp4")?.absoluteString ?? ""
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                if viewModel.shouldShowBreathingPractice {
                    StartViewForBreathingTechniques(
                        videoURL: URL(string: skyMeditationURL)!,
                        onPracticeCompleted: {
                            viewModel.shouldShowBreathingPractice = false
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
                                        MainSearchBar(searchText: $viewModel.searchText)
                                            .frame(maxWidth: .infinity)
                                            .padding(.leading, -8)
                                            .offset(x: 10)
                                            .focused($isInputActive)
                                        
                                        Spacer()
                                        
                                        if isInputActive || !viewModel.searchText.isEmpty {
                                            HStack {
                                                Button(action: {
                                                    // Сброс поиска и закрытие клавиатуры
                                                    viewModel.searchText = ""
                                                    isInputActive = false
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(uiColor: .AuraFlowBlue()))
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
                                                Button(action: {
                                                    // Меняем текущую вкладку на профиль
                                                    selectedTab = .profile
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(uiColor: .AuraFlowBlue()))
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
                                    .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 40) + 10)
                                    .padding(.bottom, 20)
                                    
                                    if isInputActive {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(tags, id: \.self) { tag in
                                                    Button(action: {
                                                        DispatchQueue.main.async {
                                                            viewModel.searchText = tag
                                                            isInputActive = true
                                                        }
                                                    }) {
                                                        Text(tag)
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 6)
                                                            .background(Color(uiColor: .AuraFlowBlue()).opacity(0.2))
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
                                
                                if viewModel.searchText.isEmpty && !isInputActive {
                                    
                                    
                                    ScrollView(showsIndicators: false) {
                                        VStack {
                                            HStack {
                                                Text("Специально для вас")
                                                    .font(Font.custom("Montserrat-Regular", size: 26))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                
                                                Spacer()
                                                
                                                NavigationLink(destination: AllAlbumsView(navigationPath: $viewModel.navigationPath)) {
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
                                                        MeditationAlbumView(album: album, width: UIScreen.main.bounds.width * 0.51, height: 210, navigationPath: $viewModel.navigationPath)
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
                                                    ForEach(viewModel.meditations) { meditation in
                                                        if viewModel.isLoading {
                                                            MeditationViewPlaceholder()
                                                        } else {
                                                            MeditationView(meditation: meditation)
                                                        }
                                                    }
                                                }
                                                .padding(.top, 10)
                                                .padding(.bottom, playbackManager.isMiniPlayerVisible ? 220 : 100)
                                            
                                        }
                                    }
                                    .padding(.top, -20)
                                    .padding(.bottom, viewModel.keyboardHeight)
                                } else {
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 60) {
                                            if !viewModel.filteredAlbums.isEmpty {
                                                Text("Альбомы")
                                                    .font(Font.custom("Montserrat-Regular", size: 24))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                    .padding(.leading, 16)
                                                    .padding(.top, 20)
                                                    .padding(.bottom, -20)
                                                
                                                ForEach(viewModel.filteredAlbums) { album in
                                                    MeditationAlbumView(album: album, width: UIScreen.main.bounds.width - 40, height: 100, navigationPath: $viewModel.navigationPath)
                                                }
                                            }
                                            
                                            if !viewModel.filteredMeditations.isEmpty {
                                                Text("Медитации")
                                                    .font(Font.custom("Montserrat-Regular", size: 24))
                                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                                    .padding(.leading, 16)
                                                
                                                ForEach(viewModel.filteredMeditations) { meditation in
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
                                    .padding(.bottom, isInputActive ? viewModel.keyboardHeight + 120 : (playbackManager.isMiniPlayerVisible ? viewModel.keyboardHeight + 150 : viewModel.keyboardHeight + 40))
                                }
                            }
                            .navigationBarHidden(true)
                            .onTapGesture {
                                isInputActive = false
                            }
                        }
                        .offset(y: UIScreen.main.bounds.height == 667 ? viewModel.keyboardHeight / 2.25 : viewModel.keyboardHeight / 2.30)
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                            viewModel.updateKeyboardHeight(notification)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                            viewModel.resetKeyboardHeight()
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .ignoresSafeArea(.keyboard, edges: .all)
                    }
                }
                
                VStack {
                    Spacer()
                    if playbackManager.isMiniPlayerVisible && playbackManager.currentMeditation != nil {
                        MiniPlayerView(playbackManager: playbackManager)
                            .frame(width: UIScreen.main.bounds.width)
                            .padding(.bottom, 50)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            viewModel.loadMeditations()
            viewModel.shouldShowBreathingPractice = UserDefaults.standard.bool(forKey: "launchWithBreathingPractice")
        }
    }
}
