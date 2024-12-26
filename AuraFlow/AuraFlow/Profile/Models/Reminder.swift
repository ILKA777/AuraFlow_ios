//
//  Reminder.swift
//  Calliope
//
//  Created by Илья on 08.08.2024.
//

import Foundation

struct Reminder: Identifiable {
    var id: UUID
    var type: ReminderType
    var startTime: Date?
    var endTime: Date?
    var frequency: Int?
    
    enum ReminderType: String {
        case motivation = "Мотивация"
        case focus = "Фокус внимания"
    }
}
