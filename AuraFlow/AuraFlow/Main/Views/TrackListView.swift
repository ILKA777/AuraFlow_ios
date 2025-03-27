//
//  TrackListView.swift
//  AuraFlow
//
//  Created by Ilya on 04.03.2025.
//

import SwiftUI

struct TrackListView: View {
    let album: MeditationAlbum
    let onTrackSelected: (Meditation) -> Void
    @ObservedObject private var playbackManager = PlaybackManager.shared
    @State private var selectedMeditation: Meditation? = nil  // Состояние для хранения выбранной медитации
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    dismiss()  // Закрытие треклиста
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
                
                Text(album.title)
                    .font(Font.custom("Montserrat-Semibold", size: 20))
                    .padding()
                
                Spacer()
            }
            
            List {
                ForEach(album.tracks, id: \.id) { meditation in
                    Button(action: {
                        // Запуск альбома с выбранного трека
                        onTrackSelected(meditation)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(meditation.title)
                                    .font(Font.custom("Montserrat-Semibold", size: 19))
                                    .foregroundColor(isPlayingThisMeditation(meditation) ? Color(uiColor: .AuraFlowBlue()) : .white)  // Изменение цвета текущего трека
                                
                                Text(meditation.date)
                                    .font(Font.custom("Montserrat-Regular", size: 14))
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
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)  // Убираем фоновый цвет списка
            .background(Color.clear)  // Прозрачный фон
        }
        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))  // Полупрозрачный фон для стиля
    }
    
    // Проверка, играется ли текущий трек
    private func isPlayingThisMeditation(_ meditation: Meditation) -> Bool {
        playbackManager.currentMeditation?.id == meditation.id
    }
}
