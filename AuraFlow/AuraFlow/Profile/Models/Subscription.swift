//
//  Subscription.swift
//  Calliope
//
//  Created by Илья on 08.08.2024.
//

import Foundation

struct Subscription: Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let type: SubscriptionType
    
    enum SubscriptionType: String {
        case monthly = "Ежемесячная"
        case yearly = "Ежегодная"
        case weekly = "Еженедельная"
    }
}
