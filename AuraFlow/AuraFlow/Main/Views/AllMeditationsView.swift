//
//  AllMeditationsView.swift
//  Calliope
//
//  Created by Илья on 15.08.2024.
//  Updated: 17.04.2025 – добавлена подгрузка медитаций с сервера, индикатор
//  загрузки и фильтрация по поиску.
//

import SwiftUI

// MARK: – ViewModel
final class AllMeditationsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var meditations: [Meditation] = []
    @Published var isLoading: Bool = true

    // Фильтрованные медитации для отображения
    var filteredMeditations: [Meditation] {
        guard !searchText.isEmpty else { return meditations }
        return meditations.filter { m in
            m.title.lowercased().contains(searchText.lowercased()) ||
            m.author.lowercased().contains(searchText.lowercased())
        }
    }

    /// Загрузка списка медитаций с бэкенда
    func load() {
        isLoading = true
        NetworkService.shared.fetchMeditations { [weak self] meditations in
            DispatchQueue.main.async {
                self?.meditations = meditations
                self?.isLoading = false
            }
        }
    }
}

// MARK: – View
struct AllMeditationsView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearching: Bool
    @StateObject private var viewModel = AllMeditationsViewModel()

    // MARK: – UI
    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(
            Image("default")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .onAppear { viewModel.load() }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: – Subviews
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.7))
                        .frame(width: 48, height: 48)
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
            .padding(.leading, 16)

            ZStack(alignment: .center) {
                if !isSearching {
                    Text("Медитации")
                        .font(.system(size: 22).bold())
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .transition(.opacity)
                        .padding(.trailing, 65)
                        
                }

                CustomSearchbar(searchText: $viewModel.searchText)
                    .focused($isSearching)
                    .onTapGesture { withAnimation { isSearching = true } }
            }
           // .padding(.trailing, 16)
        }
        .padding(.vertical, 8)
        .ignoresSafeArea(.keyboard)
    }

    private var content: some View {
        ScrollView {
            if viewModel.isLoading {
                VStack(spacing: 40) {
                    ForEach(0..<6) { _ in MeditationViewPlaceholder() }
                }
                .padding(.top, 30)
            } else {
                LazyVStack(spacing: 40) {
                    ForEach(viewModel.filteredMeditations) { meditation in
                        MeditationView(meditation: meditation)
                    }
                }
                .padding(.top, 30)
            }
        }
        .onTapGesture { hideKeyboard() }
    }
}

// MARK: – Preview
#Preview {
    AllMeditationsView()
}

