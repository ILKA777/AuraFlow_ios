//
//  Purchase.swift
//  Calliope
//
//  Created by Илья on 07.08.2024.
//

import Foundation

struct Purchase: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let amount: String
}
