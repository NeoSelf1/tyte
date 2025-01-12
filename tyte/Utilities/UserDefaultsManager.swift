/// 앱의 영구 데이터 저장소를 관리하는 싱글톤 클래스
///
/// UserDefaults를 사용하여 앱의 상태, 설정 및 사용자 데이터를 관리합니다.
/// App Group을 통해 위젯과 데이터를 공유할 수 있도록 구성되어 있습니다.
///
/// - Important: 앱과 위젯 간의 데이터 동기화를 위해 group.com.neox.tyte App Group을 사용합니다.
/// - Note: 데이터 무결성을 위해 private(set) 프로퍼티를 사용하여 외부 수정을 제한합니다.
import Foundation
import Combine
import WidgetKit

/// namespace로서의 역할만 필요한 경우:
/// - struct와 enum 모두 namespace 역할을 할 수 있음
/// - 이 경우 모든 프로퍼티가 static이므로 인스턴스화할 필요가 없음
/// - enum은 case를 필요로 하지만, 이 경우 case가 필요없는 순수 네임스페이스임
struct UserDefaultsConfiguration {
    static let suiteName = "group.com.neox.tyte"
    
    struct Keys {
        static let isLoggedIn = "isLoggedIn"
        static let appleUserEmails = "appleUserEmails"
        static let currentUserId = "currentUserId"
        static let isDarkMode = "isDarkMode"
    }
}

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

    // MARK: - Methods
    func saveAppleUserEmail(_ email: String, for userId: String) {
        appleUserEmails[userId] = email
    }
    
    func getAppleUserEmail(for userId: String) -> String? {
        return appleUserEmails[userId]
    }
    
    /// - UserDefaults 업데이트 -> AppState의 isLoggedIn 업데이트 -> UI 자동 갱신
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
