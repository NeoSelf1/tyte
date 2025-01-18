/// 보안이 필요한 데이터를 Keychain에 저장하고 관리하는 싱글톤 클래스
///
/// 액세스 토큰과 같은 민감한 인증 정보를 안전하게 저장하고 관리합니다.
/// 개발 환경에서는 더미 토큰을 사용할 수 있도록 구성되어 있습니다.
///
/// - Important: 토큰은 기기 잠금 해제 시에만 접근 가능하도록 저장됩니다.
/// - Warning: 키체인 작업 실패 시 적절한 에러 처리가 필요합니다.
import Foundation
import Security

enum KeychainError: Error {
    case unknown(OSStatus)
    case notFound
    case encodingError
}

struct KeychainConfiguration {
    static let serviceName = "com.neox.tyte"
    static let accessGroup: String? = nil
    
    struct Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
}

protocol KeychainManaging {
    func saveToken(_ accessToken: String)
    func getAccessToken() -> String?
    func clearToken()
}

final class KeychainManager:KeychainManaging {
    static let shared = KeychainManager()
    
    private init() {}
    
    func getAccessToken() -> String? {
        do {
            return APIConstants.isUserDevelopment ? "dummyToken" : try retrieve(forKey: KeychainConfiguration.Keys.accessToken)
        } catch {
            print("getAccessToken Error in KeychainManager")
            return nil
        }
    }
    
    func clearToken() {
        do {
            try delete(forKey: KeychainConfiguration.Keys.accessToken)
        } catch{
            print("clear token Error in KeychainManager")
        }
    }
    
    func saveToken(_ accessToken: String) {
        do{
            try save(token: accessToken, forKey: KeychainConfiguration.Keys.accessToken)
        } catch {
            print("Save token Error in KeychainManager")
        }
    }
}

// MARK: - 내부용 핵심 함수
private extension KeychainManager {
    func save(token: String, forKey key: String, service: String = KeychainConfiguration.serviceName) throws {
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
    
    func retrieve(forKey key: String, service: String = KeychainConfiguration.serviceName) throws -> String {
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
    
    func delete(forKey key: String, service: String = KeychainConfiguration.serviceName) throws {
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
