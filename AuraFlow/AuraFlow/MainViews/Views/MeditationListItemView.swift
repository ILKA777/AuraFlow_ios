//
//  MeditationListItemView.swift
//  Calliope
//
//  Created by Илья on 19.08.2024.
//

import SwiftUI

struct MeditationListItemView: View {
    let meditation: Meditation
    var isInputActive: Bool
    let onPlay: () -> Void // Замыкание для воспроизведения
    @ObservedObject private var playbackManager = PlaybackManager.shared // Для отслеживания текущего воспроизведения
    
    private var isPlayingThisMeditation: Bool {
        return playbackManager.currentMeditation?.id == meditation.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Контейнер для содержимого с выделением
            VStack(alignment: .leading) {
                HStack {
                    Text(meditation.title)
                        .font(Font.custom("Montserrat-Semibold", size: 19))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))

                    Spacer()

                    Text(meditation.duration)
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        .offset(x: isInputActive ? -50 : 0)
                }

                HStack {
                    Text("\(meditation.author)") // Информация об авторе
                        .font(Font.custom("Montserrat-Regular", size: 14))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                    
                    Text("•") // Информация об авторе
                        .font(Font.custom("Montserrat-Regular", size: 14))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))

                    Text(meditation.date)
                        .font(Font.custom("Montserrat-Regular", size: 14))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(isPlayingThisMeditation ? Color(uiColor: .CalliopeYellow()).opacity(0.2) : Color.clear) // Фон для выделения содержимого
            .contentShape(Rectangle()) // Для правильной области нажатия

            Divider()
                .background(Color(uiColor: .CalliopeWhite()).opacity(0.7)) // Разделитель вне области выделения
        }
        .onTapGesture {
            onPlay() // Воспроизведение медитации
        }
    }
}

// Preview (if needed)
