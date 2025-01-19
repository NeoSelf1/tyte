import Foundation
import Combine
import WidgetKit

struct UserDefaultsConfiguration {
    static let suiteName = "group.com.neox.tyte"
    
    struct Keys {
        static let isLoggedIn = "isLoggedIn"
        static let appleUserEmails = "appleUserEmails"
        static let currentUserId = "currentUserId"
        static let isDarkMode = "isDarkMode"
    }
}

/// 앱의 영구 설정을 관리하는 싱글톤 클래스입니다.
///
/// 다음과 같은 설정 관리 기능을 제공합니다:
/// - 로그인 상태 관리
/// - 사용자 기본 설정 저장
/// - 위젯과 데이터 공유
///
/// ## 사용 예시
/// ```swift
/// // 로그인 처리
/// UserDefaultsManager.shared.login(userId)
///
/// // 다크모드 설정
/// UserDefaultsManager.shared.setDarkMode(true)
/// ```
///
/// ## 관련 타입
/// - ``AppState``
/// - ``WidgetManager``
/// - ``KeychainManager``
///
/// - Note: App Group을 통해 위젯과 설정을 공유합니다.
/// - SeeAlso: ``KeychainManager``, 보안이 필요한 데이터 관리에 사용
final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults: UserDefaults!
    private let widgetManager: WidgetManager
    
    private init(
        defaults: UserDefaults = .standard,
        widgetManager: WidgetManager = .shared
    ) {
        self.defaults = defaults
        self.widgetManager = widgetManager
    }
    
    private(set) var isLoggedIn: Bool {
        get { defaults.bool(forKey: UserDefaultsConfiguration.Keys.isLoggedIn) }
        set {
            defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.isLoggedIn)
            AppState.shared.isLoggedIn = newValue // TODO: 다른 반응형 프레임워크로 환경객체 접근하는 방안 모색 필요
            widgetManager.updateWidget(.all)
        }
    }
    
    private(set) var isDarkMode: Bool {
        get { defaults.bool(forKey: UserDefaultsConfiguration.Keys.isDarkMode) }
        set { defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.isDarkMode) }
    }
    
    private(set) var appleUserEmails: [String: String] {
        get { defaults.dictionary(forKey: UserDefaultsConfiguration.Keys.appleUserEmails) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.appleUserEmails) }
    }
    
    private(set) var currentUserId: String? {
        get { defaults.string(forKey: UserDefaultsConfiguration.Keys.currentUserId) }
        set { defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.currentUserId) }
    }

    // MARK: - 내부 변수 접근위한 메서드
    func saveAppleUserEmail(_ email: String, for userId: String) {
        appleUserEmails[userId] = email
    }
    
    func getAppleUserEmail(for userId: String) -> String? {
        return appleUserEmails[userId]
    }
    
    func login(_ userId: String) {
        currentUserId = userId
        isLoggedIn = true
    }
    
    func setDarkMode(_ _isDarkMode: Bool) {
        isDarkMode = _isDarkMode
    }
    
    func logout() {
        if let userId = currentUserId {
            try? CoreDataStack.shared.clearUserData(for: userId)
        }
        
        KeychainManager.shared.clearToken()
        currentUserId = nil
        isLoggedIn = false
    }
}
