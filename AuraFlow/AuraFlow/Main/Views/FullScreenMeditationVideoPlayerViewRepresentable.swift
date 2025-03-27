//
//  Untitled.swift
//  AuraFlow
//
//  Created by Ilya on 27.03.2025.
//


import SwiftUI
import KinescopeSDK


// Обертка для SwiftUI
struct FullScreenMeditationVideoPlayerViewRepresentable: UIViewControllerRepresentable {

    var videoId: String

    // Создание и конфигурация вашего UIViewController
    func makeUIViewController(context: Context) -> FullScreenMeditationVideoPlayerViewController {
        return FullScreenMeditationVideoPlayerViewController(videoId: videoId)
    }

    // Обновление UIViewController (если это необходимо)
    func updateUIViewController(_ uiViewController: FullScreenMeditationVideoPlayerViewController, context: Context) {
        // Здесь можно обновить UI, если потребуется
    }
}

class FullScreenMeditationVideoPlayerViewController: UIViewController {

    var player: KinescopePlayer?
    var videoId: String

    // Инициализация с videoId
    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Инициализация SDK
        Kinescope.shared.setConfig(.init())

        // Инициализация плеера с videoId
        player = KinescopeVideoPlayer(config: .init(videoId: videoId,
                                                looped: false,
                                                repeatingMode: .default))

        // Создание представления для плеера
        let playerView = KinescopePlayerView()
        playerView.frame = self.view.bounds // Устанавливаем размер плеера на весь экран
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Добавляем представление плеера в иерархию представлений
        self.view.addSubview(playerView)

        // Подключаем плеер к представлению
        player?.attach(view: playerView)

        // Запускаем воспроизведение
        player?.play()
    }

    // Опционально, можно добавить обработку события при выходе из экрана или при удалении плеера
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Остановка воспроизведения при уходе с экрана
        player?.pause()
    }
}

struct FullScreenMeditationView: View {
    var videoId: String
    var body: some View {
        FullScreenMeditationVideoPlayerViewRepresentable(videoId: videoId)
            .edgesIgnoringSafeArea(.all) // Чтобы видео занимало весь экран
    }
}
