//
//  KeychainManager.swift
//  tyte
//
//  Created by 김 형석 on 9/16/24.
//

import Foundation
import Security

enum KeychainError: Error {
    case unknown(OSStatus)
    case notFound
    case encodingError
}

protocol KeychainManagerProtocol {
    func save(token: String, service: String, account: String) throws
    func retrieve(service: String, account: String) throws -> String
    func delete(service: String, account: String) throws
}

class KeychainManager:KeychainManagerProtocol {
    static let shared = KeychainManager() // 싱글톤 유지
    private init() {} // 싱글톤 유지
    
    func getToken() -> String? {
        try? self.retrieve(service: APIConstants.tokenService, account: getUserEmail() ?? "")
    }
    
    func saveToken(_ token: String, for email: String) {
        try? self.save(token: token, service: APIConstants.tokenService, account: email)
        UserDefaults.standard.set(email, forKey: "lastLoggedInEmail")
    }
    
    func clearToken() {
        guard let email = getUserEmail() else { return }
        try? self.delete(service: APIConstants.tokenService, account: email)
        UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
    }
    
    func getUserEmail() -> String? {
        UserDefaults.standard.string(forKey: "lastLoggedInEmail")
    }
    
    //MARK: - 핵심 로직
    func save(token: String, service: String, account: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, let's update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let updateAttributes: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unknown(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    func retrieve(service: String, account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            throw KeychainError.notFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        guard let data = result as? Data, let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.unknown(status)
        }
        
        return token
    }
    
    func delete(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
