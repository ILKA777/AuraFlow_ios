//
//  PlaybackManager.swift
//  Calliope
//
//  Created by Илья on 22.08.2024.
//

import AVKit
import Combine

class PlaybackManager: ObservableObject {
    static let shared = PlaybackManager()

    @Published var currentPlayer: AVPlayer? = nil
    @Published var queuePlayer: AVQueuePlayer? = nil
    @Published var isPlaying: Bool = false
    @Published var currentMeditation: Meditation? = nil
    @Published var currentAlbum: MeditationAlbum? = nil

    @Published var isMiniPlayerVisible: Bool = false

    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 1.0

    private var timeObserverToken: Any?
    private var playerItemObserver: NSKeyValueObservation?

    var currentTimeString: String {
        let currentSeconds = Int(currentTime)
        return String(format: "%02d:%02d", currentSeconds / 60, currentSeconds % 60)
    }

    var remainingTimeString: String {
        let remainingSeconds = max(0, Int(duration - currentTime))
        return String(format: "-%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    func playAlbum(album: MeditationAlbum) async {
        await stopCurrent()
        
        DispatchQueue.main.async { [weak self] in
            self?.isMiniPlayerVisible = true
            self?.currentAlbum = album
            self?.currentTime = 0.0
        }

        let items = album.tracks.map { AVPlayerItem(url: URL(string: $0.videoLink)!) }

        DispatchQueue.main.async { [weak self] in
            self?.queuePlayer = AVQueuePlayer(items: items)
        }

        DispatchQueue.main.async { [weak self] in
            self?.currentMeditation = album.tracks.first
        }

        if let firstItem = items.first {
            do {
                let loadedDuration = try await firstItem.asset.load(.duration).seconds
                DispatchQueue.main.async { [weak self] in
                    self?.duration = loadedDuration
                }
            } catch {
                print("Error loading duration: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.duration = 1.0
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.duration = 1.0
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = true
            self?.queuePlayer?.play()
        }

        setupPlayerTimeObserver()
        observeCurrentItem()
    }

    func playAlbum(from album: MeditationAlbum, startingAt meditation: Meditation) async {
        await stopCurrent()
     
        DispatchQueue.main.async { [weak self] in
            self?.isMiniPlayerVisible = true
            self?.currentAlbum = album
        }

        if let startingIndex = album.tracks.firstIndex(where: { $0.id == meditation.id }) {
            let items = album.tracks[startingIndex...].map { AVPlayerItem(url: URL(string: $0.videoLink)!) }

            DispatchQueue.main.async { [weak self] in
                self?.queuePlayer = AVQueuePlayer(items: Array(items))
            }

            DispatchQueue.main.async { [weak self] in
                self?.currentMeditation = meditation
            }

            if let firstItem = items.first {
                do {
                    let loadedDuration = try await firstItem.asset.load(.duration).seconds
                    DispatchQueue.main.async { [weak self] in
                        self?.duration = loadedDuration
                    }
                } catch {
                    print("Error loading duration: \(error)")
                    DispatchQueue.main.async { [weak self] in
                        self?.duration = 1.0
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.duration = 1.0
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.isPlaying = true
                self?.queuePlayer?.play()
            }

            setupPlayerTimeObserver()
            observeCurrentItem()
        }
    }

    func stopCurrentAudio() {
        queuePlayer?.pause()
        isPlaying = false
    }

    private func setupPlayerTimeObserver() {
        guard let player = queuePlayer else { return }
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            self.duration = player.currentItem?.duration.seconds ?? 1.0
        }
    }

    func observeCurrentItem() {
        playerItemObserver = queuePlayer?.observe(\.currentItem, options: [.new, .initial]) { [weak self] _, change in
            if let currentItem = change.newValue as? AVPlayerItem,
               let urlAsset = currentItem.asset as? AVURLAsset {
                DispatchQueue.main.async {
                    self?.currentMeditation = self?.currentAlbum?.tracks.first(where: { $0.videoLink == urlAsset.url.absoluteString })
                }
            }
        }
    }

    func skipToNextTrack() {
        queuePlayer?.advanceToNextItem()
    }

    func stopCurrent() async {
        await MainActor.run {
            isMiniPlayerVisible = false
            queuePlayer?.pause()
            queuePlayer?.removeAllItems()
            queuePlayer = nil
            currentMeditation = nil
            currentAlbum = nil
            isPlaying = false
        }
        timeObserverToken = nil

        if let observer = playerItemObserver {
            observer.invalidate()
            playerItemObserver = nil
        }
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        queuePlayer?.seek(to: cmTime)
    }

    func togglePlayPause() {
        if isPlaying {
            queuePlayer?.pause()
        } else {
            queuePlayer?.play()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying.toggle() // Переключаем состояние после изменения состояния плеера
        }
    }
}
