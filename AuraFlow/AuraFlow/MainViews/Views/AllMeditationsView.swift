//
//  AllMeditationsView.swift
//  Calliope
//
//  Created by Илья on 15.08.2024.
//

import SwiftUI

struct AllMeditationsView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputActive: Bool
    @FocusState private var isSearching: Bool
    @State private var searchText = ""
    
    let meditations = [
        sampleMeditations[0],
        sampleMeditations[1],
        sampleMeditations[2],
        sampleMeditations[3],
        sampleMeditations[4],
        sampleMeditations[5]
    ]
    
    var filteredMeditations: [Meditation] {
        if searchText.isEmpty {
            return meditations
        } else {
            return meditations.filter { meditation in
                meditation.title.lowercased().contains(searchText.lowercased()) ||
                meditation.author.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
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
                        Text("Медитации")
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
                                isSearching = true  // Activate focus on the text field
                            }
                        }
                        .padding(.trailing, -20)
                }
            }
            .ignoresSafeArea(.keyboard)
            
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(filteredMeditations.indices, id: \.self) { index in
                        MeditationView(meditation: filteredMeditations[index])
                    }
                }
                .padding(.top, 30)
            }
        }
        .background(
            Image("default")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
        )
        .onTapGesture {
            self.hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AllMeditationsView()
}
