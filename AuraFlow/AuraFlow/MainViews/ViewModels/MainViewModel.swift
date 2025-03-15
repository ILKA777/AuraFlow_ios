//
//  MainViewModel.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var keyboardHeight: CGFloat = 0
    @Published var shouldShowBreathingPractice: Bool = false
    @Published var navigationPath = NavigationPath()
    
    // Вычисляемые свойства для фильтрации
    var filteredAlbums: [MeditationAlbum] {
        if searchText.isEmpty {
            return []
        } else {
            return sampleAlbums.filter { album in
                album.title.lowercased().contains(searchText.lowercased()) ||
                album.author.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var filteredMeditations: [Meditation] {
        if searchText.isEmpty {
            return []
        } else {
            return sampleMeditations.filter { meditation in
                meditation.title.lowercased().contains(searchText.lowercased()) ||
                meditation.author.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // Методы для обработки событий клавиатуры
    func updateKeyboardHeight(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            withAnimation {
                keyboardHeight = keyboardFrame.height
            }
        }
    }
    
    func resetKeyboardHeight() {
        withAnimation {
            keyboardHeight = 0
        }
    }
}
