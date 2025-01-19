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

/// 민감한 인증 정보를 안전하게 관리하는 싱글톤 클래스입니다.
///
/// 다음과 같은 보안 기능을 제공합니다:
/// - 인증 토큰 안전한 저장/조회
/// - 기기 잠금 해제 시에만 접근 가능
/// - 앱 삭제 시 데이터 자동 제거
///
/// ## 사용 예시
/// ```swift
/// // 토큰 저장
/// KeychainManager.shared.saveToken(accessToken)
///
/// // 토큰 조회
/// if let token = KeychainManager.shared.getAccessToken() {
///     await validateToken(token)
/// }
/// ```
///
/// ## 관련 타입
/// - ``UserDefaultsManager``
/// - ``AuthenticationUseCase``
///
/// - Important: 키체인 접근 실패 시 적절한 에러 처리가 필요합니다.
/// - SeeAlso: ``UserDefaultsManager``, 일반 설정 데이터 관리에 사용
final class KeychainManager {
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
