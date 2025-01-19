//
//  MiniPlayerView.swift
//  Calliope
//
//  Created by Илья on 22.08.2024.
//

import SwiftUI
import AVKit

struct MiniPlayerView: View {
    @ObservedObject var playbackManager: PlaybackManager
    @State private var isMeditationPlayerPresented = false

    var body: some View {
        ZStack {
            // Размытие фона
            BlurView(style: .systemThinMaterial)
               // .blur(radius: 7)
            
            // Полупрозрачный белый фон
            
            
            
            
            VStack {
                if let meditation = playbackManager.currentMeditation {
                    HStack(alignment: .center, spacing: 10) {
                        // Изображение медитации
                        Image(uiImage: meditation.image)
                            .resizable()
                            .frame(width: 53, height: 53)
                            .cornerRadius(8)
                            .offset(y: -8)
                        
                        // Текст и слайдер
                        VStack(alignment: .leading, spacing: 2) {
                            // Название и автор медитации
//                            Text(meditation.title)
//                                .font(Font.custom("Montserrat-Semibold", size: 15))
//                                .lineLimit(1)
                            Marquee(text: meditation.title, font: UIFont(name: "Montserrat-Semibold", size: 15) ?? .systemFont(ofSize: 15))
                                .offset(x: -15)
                            
                            Text(meditation.author)
                                .font(Font.custom("Montserrat-Regular", size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            // Время и слайдер
                            HStack {
                                Text(playbackManager.currentTimeString)
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text(playbackManager.remainingTimeString)
                                    .font(.caption)
                            }
                            
                            UISliderView(
                                value: Binding(
                                    get: { playbackManager.currentTime },
                                    set: { newValue in
                                        playbackManager.seek(to: newValue)
                                    }
                                ),
                                minValue: 0.0,
                                maxValue: playbackManager.duration,
                                thumbColor: .clear,
                                minTrackColor: .AuraFlowBlue(),
                                maxTrackColor: .lightGray
                            )
                            .frame(height: 20)
                            .padding(.top, -5)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // Кнопка "Пауза/Воспроизведение"
                        Button(action: {
                            playbackManager.togglePlayPause()
                        }) {
                            Image(systemName: playbackManager.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        }
                        .offset(y: -20)
                      //  .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                } else {
                    // Placeholder или пустое представление, когда нет текущей медитации
                    EmptyView()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(maxHeight: 150)
        .cornerRadius(12)
        .padding(.horizontal)
        .onTapGesture {
            if playbackManager.currentMeditation != nil {
                            isMeditationPlayerPresented = true
                        }
        }
        .fullScreenCover(isPresented: $isMeditationPlayerPresented) {
            if let meditation = playbackManager.currentMeditation {
                let tempAlbum = MeditationAlbum(
                    title: "Текущая медитация",
                    author: "Сервис",
                    tracks: [meditation],
                    status: "Пополняется"
                )
                MeditationPlayerViewForMiniPlayer(meditation: meditation, album: tempAlbum)
                    .onDisappear {
                        playbackManager.isMiniPlayerVisible = true
                    }
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct UISliderView: UIViewRepresentable {
    @Binding var value: Double
    
    var minValue: Double = 0.0
    var maxValue: Double  // Передаем правильную продолжительность трека
    var thumbColor: UIColor = .clear
    var minTrackColor: UIColor = .yellow
    var maxTrackColor: UIColor = .lightGray
    
    class Coordinator: NSObject {
        var value: Binding<Double>
        let slider: UISlider
        
        init(value: Binding<Double>, slider: UISlider) {
            self.value = value
            self.slider = slider
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let slider = UISlider(frame: .zero)
        return Coordinator(value: $value, slider: slider)
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let slider = context.coordinator.slider
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(maxValue)
        slider.value = Float(value)
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.thumbTintColor = thumbColor
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        containerView.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            slider.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            slider.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let slider = context.coordinator.slider as? UISlider {
            slider.value = Float(value)
            slider.maximumValue = Float(maxValue)  // Обновляем максимальное значение только после загрузки трека
        }
    }
}




#Preview {
    MiniPlayerView(playbackManager: MockPlaybackManager())
        .previewLayout(.sizeThatFits)
}

// Mock PlaybackManager for Preview
class MockPlaybackManager: PlaybackManager {
    override init() {
        super.init()
        self.currentMeditation = Meditation(
            title: "Медитация для настройки",
            author: "Тестовый автор",
            albumStatus: "Завершен",
            date: "22 августа 2024",
            duration: "10 мин",
            videoLink: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            image: UIImage(named: "meditation1")!,
            tags: ["Тест", "Настройка"]
        )
        self.isPlaying = true
        self.currentTime = 60.0
        self.duration = 300.0
    }
}
