//
//  NetworkService.swift
//  AuraFlow
//
//  Created by Ilya on 01.02.2025.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    var url: String = "https://auraflow-main-b7f018935c7b.herokuapp.com/"
}
