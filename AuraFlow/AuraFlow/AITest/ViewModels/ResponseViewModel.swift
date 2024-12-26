//
//  ResponseViewModel.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import SwiftUI

class ResponseViewModel: ObservableObject {
    @Published var responses: [UserResponse] = []
    
    func addResponse(question: String, answer: String) {
        let newResponse = UserResponse(question: question, answer: answer)
        responses.append(newResponse)
    }
    
    func getResponse(for question: String) -> UserResponse? {
        return responses.first { $0.question == question }
    }
    
    func removeResponse(by id: UUID) {
        responses.removeAll { $0.id == id }
    }
    
    func removeLastResponse() {
        responses.removeLast()
    }
}
