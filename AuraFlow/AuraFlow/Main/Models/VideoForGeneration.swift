//
//  VideoForGeneration.swift
//  AuraFlow
//
//  Created by Ilya on 10.03.2025.
//

import SwiftUI

/// Модель автора
struct VideoForGeneration: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    
    let videoLink: String
    let imageLink: String
    
    
    // Conformance to Equatable
    static func ==(lhs: VideoForGeneration, rhs: VideoForGeneration) -> Bool {
        lhs.id == rhs.id
    }
    
}
// Получение URL для каждого видео из бандла
let forestVideoURL = Bundle.main.url(forResource: "natureMeditation", withExtension: "mp4")?.absoluteString ?? ""
let seaVideoURL = Bundle.main.url(forResource: "seaMeditation", withExtension: "mp4")?.absoluteString ?? ""
let nightVideoURL = Bundle.main.url(forResource: "nightMeditation", withExtension: "mp4")?.absoluteString ?? ""
let skyVideoURL = Bundle.main.url(forResource: "skyMeditationForGeneration", withExtension: "mp4")?.absoluteString ?? ""
let poleVideoURL = Bundle.main.url(forResource: "poleMeditation", withExtension: "mp4")?.absoluteString ?? ""
let fireVideoURL = Bundle.main.url(forResource: "fireMeditation", withExtension: "mp4")?.absoluteString ?? ""


// Обновленный список медитаций с локальными видео
let videosForGeneration = [
    VideoForGeneration(
        title: "Лес",
        videoLink: forestVideoURL,
        imageLink: "https://assets.unenvironment.org/decadeonrestoration/2020-03/nature-3294681_1280%20%281%29.jpg"
    ),
    
    VideoForGeneration(
        title: "Небо",
        videoLink: skyVideoURL,
        imageLink: "https://s6.stc.all.kpcdn.net/edu/wp-content/uploads/2024/11/pochemu-nebo-goluboe.jpg"
    ),
    
    VideoForGeneration(
        title: "Море",
        videoLink: seaVideoURL,
        imageLink: "https://img.freepik.com/premium-photo/scenic-view-sea-against-blue-sky_1048944-12445648.jpg"
    ),
    
    VideoForGeneration(
        title: "Ночь",
        videoLink: nightVideoURL,
        imageLink: "https://store.rambler.ru/horoscopes-prod/api/media/draftail/images/e2/cf/e2cf0491836d8a0254fa87637cbd8062.jpg"
    ),
    
    VideoForGeneration(
        title: "Поле",
        videoLink: poleVideoURL,
        imageLink: "https://img.freepik.com/free-photo/wheat-with-cloud_1160-55.jpg"
    ),
    
    VideoForGeneration(
        title: "Камин",
        videoLink: fireVideoURL,
        imageLink: "https://drova-mo.ru/wp-content/uploads/2018/01/maxresdefault.jpg"
    )
]
