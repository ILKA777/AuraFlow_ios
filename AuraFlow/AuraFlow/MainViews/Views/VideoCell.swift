//
//  VideoCell.swift
//  AuraFlow
//
//  Created by Ilya on 10.03.2025.
//

// VideoCell.swift
import SwiftUI

struct VideoCell: View {
    var video: VideoForGeneration
    var isSelected: Bool  // Новый параметр для определения выбранной ячейки

    var body: some View {
        VStack {
            // Асинхронная загрузка изображения с отображением рамки при выделении
            AsyncImage(url: URL(string: video.imageLink)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 109, height: 109)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .overlay(
                        // Рамка появляется, если ячейка выбрана
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 4)
                    )
            } placeholder: {
                Color.gray
                    .frame(width: 109, height: 109)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
            }
            
            // Отображение названия видео
            Text(video.title)
                .font(Font.custom("Montserrat-Regular", size: 16))
                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
        }
        .frame(width: 109, height: 150)
        .buttonStyle(PlainButtonStyle())
    }
}
