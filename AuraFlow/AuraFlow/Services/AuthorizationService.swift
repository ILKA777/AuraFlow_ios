//
//  AuthorizationService.swift
//  Calliope
//
//  Created by Илья on 08.08.2024.
//

import Foundation

final class AuthorizationService {
    static let shared = AuthorizationService()
    
    private init() {}
    
    var isLogin: Bool = false
}
