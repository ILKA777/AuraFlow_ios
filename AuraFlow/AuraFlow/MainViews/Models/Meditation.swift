//
//  Meditation.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

// Модель медитации
struct Meditation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let author: String
    let albumStatus: String
    let date: String
    let duration: String
    let videoLink: String
    let imageLink: String = ""
    let image: UIImage
    let tags: [String]
    
    // Conformance to Equatable
    static func ==(lhs: Meditation, rhs: Meditation) -> Bool {
        lhs.id == rhs.id
    }
    
    var durationFormatted: String {
        let minutes = (Int(duration) ?? 0) / 60
        let seconds = (Int(duration) ?? 0) % 60
            return String(format: "%d:%02d мин", minutes, seconds)
        }
    
}

// Получение URL для каждого видео из бандла
let morningMeditationURL = Bundle.main.url(forResource: "morningMeditation", withExtension: "mp4")?.absoluteString ?? ""
let workBreakMeditationURL = Bundle.main.url(forResource: "workMeditation", withExtension: "mp4")?.absoluteString ?? ""
let natureMeditationURL = Bundle.main.url(forResource: "natureMeditation", withExtension: "mp4")?.absoluteString ?? ""
let relaxMeditationURL = Bundle.main.url(forResource: "relaxMeditation", withExtension: "mp4")?.absoluteString ?? ""
let nightMeditationURL = Bundle.main.url(forResource: "sleepMeditation", withExtension: "mp4")?.absoluteString ?? ""
let affirmationMeditationURL = Bundle.main.url(forResource: "sampleMeditation", withExtension: "mp4")?.absoluteString ?? ""

// Обновленный список медитаций с локальными видео
let sampleMeditations = [
    Meditation(
        title: "Утренняя медитация",
        author: "Анна Долматова",
        albumStatus: "Завершен",
        date: "21 апреля 2024",
        duration: "6 мин",
        videoLink: morningMeditationURL,
        image: (UIImage(named: "meditation1") ?? UIImage(systemName: "sunrise.fill"))!,
        tags: ["Утро", "Энергия", "Пробуждение"]
    ),
    Meditation(
        title: "Рабочий перерыв",
        author: "Анна Долматова",
        albumStatus: "Завершен",
        date: "15 мая 2024",
        duration: "7 мин",
        videoLink: workBreakMeditationURL,
        image: (UIImage(named: "meditation2") ?? UIImage(systemName: "clock.fill"))!,
        tags: ["День", "Работа", "Перерыв"]
    ),
    Meditation(
        title: "Медитация на природе",
        author: "Анна Долматова",
        albumStatus: "Завершен",
        date: "10 июня 2024",
        duration: "30 мин",
        videoLink: natureMeditationURL,
        image: (UIImage(named: "meditation3") ?? UIImage(systemName: "leaf.fill"))!,
        tags: ["Природа", "Спокойствие", "Отдых"]
    ),
    Meditation(
        title: "Релаксирующая медитация",
        author: "Анна Долматова",
        albumStatus: "Завершен",
        date: "25 июля 2024",
        duration: "7 мин",
        videoLink: relaxMeditationURL,
        image: (UIImage(named: "meditation4") ?? UIImage(systemName: "cloud.fill"))!,
        tags: ["Релакс", "Спокойствие", "Отдых"]
    ),
    Meditation(
        title: "Ночная медитация",
        author: "Анна Долматова",
        albumStatus: "Завершен",
        date: "1 августа 2024",
        duration: "7 мин",
        videoLink: nightMeditationURL,
        image: (UIImage(named: "meditation5") ?? UIImage(systemName: "moon.fill"))!,
        tags: ["Ночь", "Сон", "Отдых"]
    ),
    Meditation(
        title: "Аффирмация я своей мечты",
        author: "Анна Долматова",
        albumStatus: "Завершен",
        date: "21 октября 2024",
        duration: "19 мин",
        videoLink: affirmationMeditationURL,
        image: (UIImage(named: "meditation6") ?? UIImage(systemName: "sparkles"))!,
        tags: ["Вечер", "Успех", "Самосовершенствование"]
    )
]


// Sample data
// Updated Sample Data for Albums
let sampleAlbums = [
    MeditationAlbum(
        title: "Медитация во время сна",
        author: "Сервис",
        tracks: [
            sampleMeditations[4], // "Аффирмация на конец дня"
            sampleMeditations[5], // "Медитация для сна"
            sampleMeditations[2]  // "Медитация на природе"
        ],
        status: "Альбом пополняется"
    ),
    MeditationAlbum(
        title: "Утренняя медитация",
        author: "Сервис",
        tracks: [
            sampleMeditations[0], // "Утренняя медитация"
            sampleMeditations[5], // "Рабочий перерыв"
            sampleMeditations[3]  // "Медитация на природе"
        ],
        status: "Альбом пополняется"
    ),
    MeditationAlbum(
        title: "Медитация для сна",
        author: "Сервис",
        tracks: [
            sampleMeditations[4], // "Медитация для сна"
            sampleMeditations[2], // "Аффирмация на конец дня"
            sampleMeditations[3], // "Медитация на природе"
            sampleMeditations[5]  // "Медитация на природе"
        ],
        status: "Альбом завершен"
    )
]
