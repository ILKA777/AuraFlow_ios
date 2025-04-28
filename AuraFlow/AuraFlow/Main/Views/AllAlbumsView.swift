//
//  AllAlbumsView.swift
//  Calliope
//
//  Updated: 17.04.2025 – добавлена загрузка альбомов с бэкенда, индикатор
//  загрузки и поисковая фильтрация (по образцу AllMeditationsView).
//

import SwiftUI

// MARK: – ViewModel
final class AllAlbumsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var albums: [MeditationAlbum] = []
    @Published var isLoading = true

    // Фильтрованные альбомы
    var filteredAlbums: [MeditationAlbum] {
        guard !searchText.isEmpty else { return albums }
        return albums.filter { album in
            album.title.lowercased().contains(searchText.lowercased()) ||
            album.author.lowercased().contains(searchText.lowercased())
        }
    }

    /// Загрузка альбомов с бэкенда
    func load() {
        isLoading = true
        NetworkService.shared.fetchAlbums { [weak self] albums in
            self?.albums = albums
            self?.isLoading = false
        }
    }
}

// MARK: – View
struct AllAlbumsView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearching: Bool
    @Binding var navigationPath: NavigationPath
    @StateObject private var viewModel = AllAlbumsViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = screenWidth / 2.3

        VStack(spacing: 0) {
            header

            ScrollView {
                if viewModel.isLoading {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(0..<6) { _ in MeditationAlbumViewPlaceholder(width: itemWidth, height: 200) }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.filteredAlbums.indices, id: \.self) { index in
                            MeditationAlbumView(album: viewModel.filteredAlbums[index], width: itemWidth, height: 200, navigationPath: $navigationPath)
                                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                }
            }
        }
        .background(
            Image("default")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .onAppear { viewModel.load() }
        .onTapGesture { hideKeyboard() }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: – Subviews
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
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
                    Text("Альбомы")
                        .font(.system(size: 22).bold())
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .transition(.opacity)
                        .padding(.trailing, 65)
                }

                CustomSearchbar(searchText: $viewModel.searchText)
                    .focused($isSearching)
                    .onTapGesture { withAnimation { isSearching = true } }
            }
        }
        .padding(.vertical, 8)
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: – Helpers
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: – Preview
#Preview {
    NavigationStack {
        AllAlbumsView(navigationPath: .constant(NavigationPath()))
    }
}

