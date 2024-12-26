//
//  VideoPlayerContainer.swift
//  Calliope
//
//  Created by Илья on 19.08.2024.
//

import SwiftUI
import AVKit

struct VideoPlayerContainer: UIViewControllerRepresentable {
    let videoURL: URL
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var duration: Double
    @Binding var isUserSeeking: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let playerItem = AVPlayerItem(url: videoURL)
        let player = AVPlayer(playerItem: playerItem)
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.videoGravity = .resizeAspectFill

        // Assign the player to the coordinator
        context.coordinator.player = player

        // Add time observer
        context.coordinator.addPeriodicTimeObserver()

        // Load video duration
//        player.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
//            var error: NSError? = nil
//            let status = player.currentItem?.asset.statusOfValue(forKey: "duration", error: &error)
//            if status == .loaded {
//                let durationSeconds = player.currentItem?.asset.duration.seconds ?? 0
//                DispatchQueue.main.async {
//                    self.duration = durationSeconds
//                }
//            }
//        }
//        
        Task {
            guard let asset = player.currentItem?.asset else { return }
            do {
                let duration = try await asset.load(.duration)
                DispatchQueue.main.async {
                    self.duration = duration.seconds
                }
            } catch {
                print("Failed to load duration: \(error.localizedDescription)")
            }
        }

        // Seek to currentTime when ready
        player.currentItem?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600), completionHandler: { _ in
            // Optionally do something after seeking
        })

        // Add observer for end of playback
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerItemDidReachEnd(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard let player = context.coordinator.player else { return }

        // Control playback
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }

        // Seek if user is seeking
        if isUserSeeking {
            let targetTime = CMTime(seconds: currentTime, preferredTimescale: 600)
            player.seek(to: targetTime) { [self] _ in
                DispatchQueue.main.async {
                    self.isUserSeeking = false
                }
            }
        }
    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        // Remove the time observer
        if let token = coordinator.timeObserverToken {
            coordinator.player?.removeTimeObserver(token)
            coordinator.timeObserverToken = nil
        }
        // Remove observer for end of playback
        NotificationCenter.default.removeObserver(
            coordinator,
            name: .AVPlayerItemDidPlayToEndTime,
            object: uiViewController.player?.currentItem
        )
    }

    // MARK: - Coordinator Class

    class Coordinator: NSObject {
        var parent: VideoPlayerContainer
        var timeObserverToken: Any?
        var player: AVPlayer?

        init(parent: VideoPlayerContainer) {
            self.parent = parent
        }

        deinit {
            if let token = timeObserverToken {
                player?.removeTimeObserver(token)
                timeObserverToken = nil
            }
        }

        func addPeriodicTimeObserver() {
            guard let player = self.player else { return }
            let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = player.addPeriodicTimeObserver(
                forInterval: interval,
                queue: .main
            ) { [weak self] time in
                guard let self = self else { return }
                if !self.parent.isUserSeeking {
                    self.parent.currentTime = time.seconds
                }
            }
        }

        @objc func playerItemDidReachEnd(_ notification: Notification) {
            DispatchQueue.main.async {
                self.parent.isPlaying = false
            }
        }
    }
}
