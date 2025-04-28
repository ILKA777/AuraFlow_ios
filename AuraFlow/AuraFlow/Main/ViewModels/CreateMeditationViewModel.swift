//  CreateMeditationViewModel.swift
//  AuraFlow
//
//  Added subscription-based generation limits and monthly reset

import SwiftUI
import Combine

// MARK: - Response Models
struct PollingResponse: Decodable {
    let status: String
    let url: String
    let wasUsed: String?
}

final class CreateMeditationViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var duration: Double = 5
    @Published var melodyPrompt: String = ""
    @Published var meditationPrompt: String = ""
    @Published var audioPrompt: String = ""
    @Published var selectedVideo: VideoForGeneration? = nil
    
    @Published var showPopup: Bool = false
    @Published var navigateToPlayer: Bool = false
    @Published var generatedAudioURL: URL? = nil
    @Published var meditationId: String? = nil
    @Published var showNoAttemptsAlert = false
    private var pollingTimer: Timer?
    
    // MARK: - Generation attempt limits
    var totalAttempts: Int {
        NetworkService.shared.hasSubscription() ? 10 : 3
    }
    @Published var remainingAttempts: Int = 0
    
    // MARK: - Storage keys
    private let attemptsKey = "remainingAttempts"
    private let lastResetKey = "attemptsLastReset"
    
    // MARK: - Dependencies
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init() {
        let defaults = UserDefaults.standard
        let saved = defaults.integer(forKey: attemptsKey)
        remainingAttempts = (saved > 0) ? min(saved, totalAttempts) : totalAttempts
        
        if let lastReset = defaults.object(forKey: lastResetKey) as? Date {
            if !Calendar.current.isDate(Date(), equalTo: lastReset, toGranularity: .month) {
                resetMonthly()
            }
        } else {
            resetMonthly()
        }
        
        NotificationCenter.default.publisher(for: .didChangeSubscriptionStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshLimits()
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Monthly reset
    private func resetMonthly() {
        remainingAttempts = totalAttempts
        let now = Date()
        let defaults = UserDefaults.standard
        defaults.set(remainingAttempts, forKey: attemptsKey)
        defaults.set(now, forKey: lastResetKey)
    }
    
    // MARK: - Duration controls
    func decrementDuration() {
        if duration > 1 {
            duration -= 1
        }
    }
    
    func incrementDuration() {
        if duration < 30 {
            duration += 1
        }
    }
    
    // MARK: - Actions
    func createMeditation() {
        
        guard remainingAttempts > 0 else {
            showNoAttemptsAlert = true
            return
        }
        
        showPopup = true
        
        guard let url = URL(string: "https://auraflow-main1-0eeb7f198893.herokuapp.com/meditation-generate") else {
            print("Invalid URL")
            showPopup = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = NetworkService.shared.getAuthToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "topic": meditationPrompt,
            "duration": Int(duration),
            "melody": audioPrompt
        ]
        
        print("topic \(meditationPrompt)")
        print("duration \(Int(duration))")
        print("melody \(audioPrompt)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, _ in
                guard let idString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(charactersIn: "\"\n ")) else {
                    throw URLError(.badServerResponse)
                }
                return idString
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Generate failed: \(error)")
                    self.showPopup = false
                }
            }, receiveValue: { id in
                self.startPolling(with: id)
            })
            .store(in: &cancellables)
    }
    
    private func startPolling(with id: String) {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.checkStatus(id: id)
        }
        pollingTimer?.fire()
    }
    
    private func checkStatus(id: String) {
        guard var components = URLComponents(string: "https://auraflow-main1-0eeb7f198893.herokuapp.com/meditation-generate") else {
            return
        }
        
        print("айди \(id)")
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = NetworkService.shared.getAuthToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PollingResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Polling error: \(error)")
                }
            }, receiveValue: { response in
                if response.status == "ready", let link = URL(string: response.url) {
                    self.remainingAttempts = max(0, self.remainingAttempts - 1)
                    UserDefaults.standard.set(self.remainingAttempts, forKey: self.attemptsKey)
                    self.pollingTimer?.invalidate()
                    self.meditationId = id
                    self.generatedAudioURL = link
                    self.showPopup = false
                    self.navigateToPlayer = true
                }
            })
            .store(in: &cancellables)
    }
}
extension CreateMeditationViewModel {
    /// Перезапрос оставшихся попыток с учётом текущего totalAttempts
    func refreshLimits() {
        let defaults = UserDefaults.standard
        let saved = defaults.integer(forKey: attemptsKey)
        // Never top-up, only ensure we never exceed `totalAttempts`
        remainingAttempts = min(saved, totalAttempts)
        defaults.set(remainingAttempts, forKey: attemptsKey)
    }
}
