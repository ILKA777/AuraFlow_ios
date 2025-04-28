//
//  AuraFlowTests.swift
//  AuraFlowTests
//
//  Created by Ilya on 25.04.2025.
//

import XCTest
import SwiftUI
import AVKit
@testable import AuraFlow

final class AuraFlowTests: XCTestCase {

    func testAuthorDefaultWhenNil() {
        // При передаче author = nil должен подставляться "Сервис"
        let meditation = Meditation(
            title: "Тест",
            author: nil,
            date: "2025-04-25",
            duration: "60",
            videoLink: "link",
            image: UIImage(),
            tags: []
        )
        XCTAssertEqual(meditation.author, "Сервис")
    }

    func testDurationFormatted() {
        // 125 секунд = 2 минуты 5 секунд → "2:05 мин"
        let m1 = Meditation(
            title: "T",
            author: "A",
            date: "2025-04-25",
            duration: "125",
            videoLink: "link",
            image: UIImage(),
            tags: []
        )
        XCTAssertEqual(m1.durationFormatted, "2:05 мин")

        // ровно 60 сек → "1:00 мин"
        let m2 = Meditation(
            title: "T",
            author: "A",
            date: "2025-04-25",
            duration: "60",
            videoLink: "link",
            image: UIImage(),
            tags: []
        )
        XCTAssertEqual(m2.durationFormatted, "1:00 мин")

        // ноль секунд → "0:00 мин"
        let m3 = Meditation(
            title: "T",
            author: "A",
            date: "2025-04-25",
            duration: "0",
            videoLink: "link",
            image: UIImage(),
            tags: []
        )
        XCTAssertEqual(m3.durationFormatted, "0:00 мин")
    }

    func testImageAndTagsAreOverriddenToDefaults() {
        let customImage = UIImage(systemName: "star.fill")!
        let customTags = ["one", "two"]

        let meditation = Meditation(
            title: "Test",
            author: "A",
            date: "2025-04-25",
            duration: "30",
            videoLink: "link",
            image: customImage,
            tags: customTags
        )

        // image в инициализаторе переопределяется на ресурс из assets или systemName "sunrise.fill"
        XCTAssertNotEqual(meditation.image.pngData(), customImage.pngData())

        // tags игнорируются и всегда ["Тестовый тег", "Медитация", "AuraFlow"]
        XCTAssertEqual(
            meditation.tags,
            ["Тестовый тег", "Медитация", "AuraFlow"]
        )
    }
}

final class MeditationAlbumTests: XCTestCase {

    func testTrackCount() {
        let track1 = Meditation(
            title: "One",
            author: "A",
            date: "2025-04-25",
            duration: "10",
            videoLink: "l1",
            image: UIImage(),
            tags: []
        )
        let track2 = Meditation(
            title: "Two",
            author: "B",
            date: "2025-04-25",
            duration: "20",
            videoLink: "l2",
            image: UIImage(),
            tags: []
        )

        let album = MeditationAlbum(
            title: "Album",
            author: "Author",
            tracks: [track1, track2],
            status: "New"
        )
        XCTAssertEqual(album.trackCount, 2)
    }

    func testEquatableByIdentity() {
        let album1 = MeditationAlbum(
            title: "Same",
            author: "A",
            tracks: [],
            status: "S"
        )
        // Рефлексивность
        XCTAssertEqual(album1, album1)

        let album2 = MeditationAlbum(
            title: "Same",
            author: "A",
            tracks: [],
            status: "S"
        )
        // Разные id → не равны, даже если все остальные поля совпадают
        XCTAssertNotEqual(album1, album2)
    }
}

// Небольшие заглушки для плеера и сервисов
final class FakeQueuePlayer: AVQueuePlayer {
    var didAdvance = false
    var didPlay = false
    var didPause = false
    var lastSeekTime: CMTime?

    override func advanceToNextItem() {
        didAdvance = true
    }
    override func play() {
        didPlay = true
    }
    override func pause() {
        didPause = true
    }

    // ПЕРЕОПРЕДЕЛИМ ПРОСТУЮ ВЕРСИЮ SEEK
    override func seek(to time: CMTime) {
        lastSeekTime = time
    }

    // Можно удалить или оставить, на ваше усмотрение
    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        lastSeekTime = time
    }
}


final class FakeStatisticService: StatisticService {
    override var meditationMinutes: Double {
        get { storedMinutes }
        set { storedMinutes = newValue }
    }
    var storedMinutes: Double = 0
}

final class PlaybackManagerTests: XCTestCase {
    var sut: PlaybackManager!
    var fakePlayer: FakeQueuePlayer!
    var fakeStats: FakeStatisticService!

    override func setUp() {
        super.setUp()
        sut = PlaybackManager.shared

        fakePlayer = FakeQueuePlayer()
        sut.queuePlayer = fakePlayer

        // Подменяем сервис статистики
        fakeStats = FakeStatisticService()
        StatisticService.shared = fakeStats
    }

    override func tearDown() {
        // Важно: привести синглтон к чистому состоянию
        sut.stopCurrentAudio()
        sut.queuePlayer = nil
        sut = nil
        super.tearDown()
    }

    func testCurrentTimeAndRemainingTimeStrings() {
        sut.currentTime = 65    // 1:05
        sut.duration = 200      // 3:20 всего
        XCTAssertEqual(sut.currentTimeString, "01:05")
        XCTAssertEqual(sut.remainingTimeString, "-02:15")
    }

    func testTogglePlayPause_fromStopped_startsPlaybackAndSetsIsPlaying() {
        sut.isPlaying = false
        sut.playSessionStart = nil
        fakePlayer.didPlay = false

        let exp = expectation(description: "Main queue tasks")
        sut.togglePlayPause()

        // Отложенно, после того как main-очередь выполнит всё, что отложили:
        DispatchQueue.main.async {
            XCTAssertTrue(self.sut.isPlaying, "isPlaying должен стать true")
            XCTAssertNotNil(self.sut.playSessionStart, "playSessionStart должен быть установлен")
            XCTAssertTrue(self.fakePlayer.didPlay, "должен быть вызван play()")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testTogglePlayPause_fromPlaying_pausesAndAccumulatesStatistics() {
        sut.isPlaying = true
        // зафиксируем playSessionStart 120 секунд назад
        sut.playSessionStart = Date(timeIntervalSinceNow: -120)
        fakeStats.storedMinutes = 0
        fakePlayer.didPause = false

        let exp = expectation(description: "Main queue tasks")
        sut.togglePlayPause()

        DispatchQueue.main.async {
            XCTAssertFalse(self.sut.isPlaying, "isPlaying должен стать false")
            XCTAssertTrue(self.fakePlayer.didPause, "должен быть вызван pause()")
            // 120 сек = 2.0 минуты
            XCTAssertGreaterThanOrEqual(self.fakeStats.storedMinutes, 2.0, "должны накопиться 2 минуты")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testSkipToNextTrack_callsAdvanceOnQueuePlayer() {
        sut.skipToNextTrack()
        XCTAssertTrue(fakePlayer.didAdvance)
    }

    func testSeek_invokesSeekWithCorrectTime() {
        let target = 42.5
        sut.seek(to: target)

        let last = fakePlayer.lastSeekTime?.seconds ?? -1
        XCTAssertEqual(last, target, accuracy: 0.001)
    }

    func testStopCurrentAudio_pausesAndSetsIsPlayingFalse() {
        sut.isPlaying = true
        sut.stopCurrentAudio()
        XCTAssertFalse(sut.isPlaying)
        XCTAssertTrue(fakePlayer.didPause)
    }

    func testStopCurrent_resetsAllStateAndAddsStatistics() async {
        // Подготовка: запустить сессию
        sut.queuePlayer = fakePlayer
        sut.playSessionStart = Date(timeIntervalSinceNow: -90) // 1.5 мин назад
        sut.isMiniPlayerVisible = true
        sut.currentAlbum = MeditationAlbum(title: "A", author: "B", tracks: [], status: "")
        sut.currentMeditation = Meditation(
            title: "T", author: "A", date: "d", duration: "10", videoLink: "l", image: UIImage(), tags: []
        )

        await sut.stopCurrent()

        XCTAssertFalse(sut.isMiniPlayerVisible)
        XCTAssertNil(sut.queuePlayer)
        XCTAssertNil(sut.currentAlbum)
        XCTAssertNil(sut.currentMeditation)
        // Должно отплюсовать 1.5 минуты
        XCTAssertGreaterThanOrEqual(fakeStats.storedMinutes, 1.5)
    }
}
