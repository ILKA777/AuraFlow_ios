//
//  KeychainService.swift
//  AuraFlow
//
//  Created by Ilya on 31.03.2025.
//

import Foundation
import Security

class KeychainService {
    
    static let shared = KeychainService()
    
    private init() {}
    
    func save(token: String) {
        let data = token.data(using: .utf8)!
        
        // Create a query to store the token
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecValueData as String: data
        ]
        
        // Delete any existing data before saving the new token
        SecItemDelete(query as CFDictionary)
        
        // Add the token to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error saving token to Keychain: \(status)")
        }
    }
    
    func retrieve() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            print("Error retrieving token from Keychain: \(status)")
            return nil
        }
    }
    
    func delete() {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "authToken"
            ]
            SecItemDelete(query as CFDictionary)
        }
}
