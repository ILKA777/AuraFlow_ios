//
//  MeditationAlbum.swift
//  Calliope
//
//  Created by Илья on 13.08.2024.
//

import Foundation

struct MeditationAlbum: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let author: String
    let tracks: [Meditation]
    let status: String
    
    var trackCount: Int {
        tracks.count
    }
    // Conformance to Equatable
        static func ==(lhs: MeditationAlbum, rhs: MeditationAlbum) -> Bool {
            lhs.id == rhs.id
        }
}
