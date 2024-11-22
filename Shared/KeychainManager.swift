import Foundation
import Security

enum KeychainError: Error {
    case unknown(OSStatus)
    case notFound
    case encodingError
}

enum KeychainKeys {
    static let serviceName = "com.clip.tyte"
    
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
}

protocol KeychainManagerProtocol {
    func saveToken(_ accessToken: String)
    func getAccessToken() -> String?
    func clearToken()
}

class KeychainManager:KeychainManagerProtocol {
    static let shared = KeychainManager()
    
    private init() {}
    
    func getAccessToken() -> String? {
        do {
            return APIConstants.isUserDevelopment ? "dummyToken" : try retrieve(forKey: KeychainKeys.accessToken)
        } catch {
            print("getAccessToken Error in KeychainManager")
            return nil
        }
    }
    
    func clearToken() {
        do {
            try delete(forKey: KeychainKeys.accessToken)
        } catch{
            print("clear token Error in KeychainManager")
        }
    }
    
    func saveToken(_ accessToken: String) {
        do{
            try save(token: accessToken, forKey: KeychainKeys.accessToken)
        } catch {
            print("Save token Error in KeychainManager")
        }
    }
}

// MARK: - 내부용 핵심 함수
private extension KeychainManager {
    func save(token: String, forKey key: String, service: String = KeychainKeys.serviceName) throws {
        guard let data = token.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, let's update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
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
    
    func retrieve(forKey key: String, service: String = KeychainKeys.serviceName) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
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
    
    func delete(forKey key: String, service: String = KeychainKeys.serviceName) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
