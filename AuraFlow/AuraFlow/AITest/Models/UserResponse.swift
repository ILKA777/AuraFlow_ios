//
//  UserResponse.swift
//  Calliope
//
//  Created by Илья on 12.08.2024.
//

import Foundation

struct UserResponse: Identifiable {
    let id: UUID
    let question: String
    let answer: String
    
    init(question: String, answer: String) {
        self.id = UUID() // Automatically generate a unique ID
        self.question = question
        self.answer = answer
    }
}
