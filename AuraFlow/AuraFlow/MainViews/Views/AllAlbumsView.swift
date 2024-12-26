//
//  AllAlbumsView.swift
//  Calliope
//
//  Created by Илья on 15.08.2024.
//

import SwiftUI

struct AllAlbumsView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputActive: Bool
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isSearching: Bool // State to track search bar visibility
    @State private var searchText = "" // State to track search query
    @Binding var navigationPath: NavigationPath
    // Sample data for 10 unique albums
    let albums = [
        MeditationAlbum(
            title: "Медитация во время сна",
            author: "Сервис",
            tracks: [
                sampleMeditations[4], // "Аффирмация на конец дня"
                sampleMeditations[5], // "Медитация для сна"
                sampleMeditations[2]  // "Медитация на природе"
            ],
            status: "Альбом пополняется"
        ),
        MeditationAlbum(
            title: "Утренняя медитация",
            author: "Сервис",
            tracks: [
                sampleMeditations[0], // "Утренняя медитация"
                sampleMeditations[5], // "Рабочий перерыв"
                sampleMeditations[3]  // "Медитация на природе"
            ],
            status: "Альбом пополняется"
        ),
        MeditationAlbum(
            title: "Медитация для сна",
            author: "Сервис",
            tracks: [
                sampleMeditations[4], // "Медитация для сна"
                sampleMeditations[2], // "Аффирмация на конец дня"
                sampleMeditations[3], // "Медитация на природе"
                sampleMeditations[5]  // "Медитация на природе"
            ],
            status: "Альбом завершен"
        )
    ]

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var filteredAlbums: [MeditationAlbum] {
        if searchText.isEmpty {
            return albums
        } else {
            return albums.filter { album in
                album.title.lowercased().contains(searchText.lowercased()) ||
                album.author.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = screenWidth / 2.3  // 20 points padding on both sides + 20 points between columns
        
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
                        Text("Альбомы")
                            .font(.system(size: 22).bold())
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(.leading, 16)
                            .padding(.trailing, 16 + 20 + 48)
                            .transition(.opacity)
                            .animation(.easeInOut, value: isSearching)
                    }
                    
                    CustomSearchbar(searchText: $searchText)
                        .padding(.trailing, 16)
                        .focused($isSearching)
                        .onTapGesture {
                            withAnimation {
                                isSearching = true  // Включаем фокус на текстовое поле
                            }
                        }
                        .padding(.trailing, -20)
                }
            }
           // .padding(.top, 30)
            .ignoresSafeArea(.keyboard)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredAlbums.indices, id: \.self) { index in
                        MeditationAlbumView(album: filteredAlbums[index], width: itemWidth, height: 200, navigationPath: $navigationPath)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
        }
        .onTapGesture {
            self.hideKeyboard() // Hide keyboard when tapping outside
        }
        .background(
            Image("default")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

