//
//  FullScreenMeditationVideoPlayerView.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI
import AVKit
import Charts

struct FullScreenMeditationVideoPlayerView: View {
    let videoURL: URL
    let audioURL = URL(string: "https://storage.googleapis.com/auraflow_bucket/audio/meditation_20250310_144922_1ae4b501.mp3")!
    
    @Environment(\.dismiss) private var dismiss
    @State private var videoPlayer = AVPlayer()
    @State private var audioPlayer = AVPlayer()
    
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var playbackManager = PlaybackManager.shared
    
    @StateObject private var heartRateReceiver = HeartRateReceiver()
    @State private var heartRateHistory: [Double] = []
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VideoPlayer(player: videoPlayer)
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        if playbackManager.isPlaying {
                            await playbackManager.stopCurrent()
                        }
                        
                        let videoItem = AVPlayerItem(url: videoURL)
                        videoPlayer.replaceCurrentItem(with: videoItem)
                        videoPlayer.play()
                        
                        let audioItem = AVPlayerItem(url: audioURL)
                        audioPlayer.replaceCurrentItem(with: audioItem)
                        audioPlayer.play()
                    }
                    
                    Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                        let currentHR = heartRateReceiver.heartRate
                        heartRateHistory.append(currentHR)
                        if heartRateHistory.count > 20 {
                            heartRateHistory.removeFirst()
                        }
                    }
                }
                .onDisappear {
                    videoPlayer.pause()
                    videoPlayer.replaceCurrentItem(with: nil)
                    
                    audioPlayer.pause()
                    audioPlayer.replaceCurrentItem(with: nil)
                }
            
            if healthKitManager.showPulseDuringVideo {
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Пульс")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 4)
                            
                            Text("\(Int(heartRateReceiver.heartRate)) BPM")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 5)
                            
                            Chart {
                                ForEach(heartRateHistory.indices, id: \..self) { index in
                                    LineMark(
                                        x: .value("Time", index),
                                        y: .value("Heart Rate", heartRateHistory[index])
                                    )
                                    .interpolationMethod(.monotone)
                                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [.red, .orange]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic)
                            }
                            .chartXScale(domain: 0...max(Double(heartRateHistory.count) + 30, 30))
                            .frame(width: 150, height: 100)
                            .padding(.horizontal, 10)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
    }
}



#Preview {
    CreateMeditationView()
}
