import Foundation
import Combine
import WidgetKit

struct UserDefaultsConfiguration {
    static let suiteName = "group.com.neox.tyte"
    
    struct Keys {
        static let isLoggedIn = "isLoggedIn"
        static let appleUserEmails = "appleUserEmails"
        static let dailyStats = "dailyStats"
        static let currentUserId = "currentUserId"
    }
}

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults: UserDefaults!
    
    private init(defaults: UserDefaults = .standard) {
        let groupDefaults = UserDefaults(suiteName: UserDefaultsConfiguration.suiteName)!
        self.defaults = groupDefaults
    }
    
    // MARK: - 속성들 캡슐화와 데이터 무결성을 보장하기 위해 private(set) 사용 ->  클래스 내부에서만 수정 가능
    // 읽기는 public, 쓰기는 private
    private(set) var isLoggedIn: Bool {
        get { defaults.bool(forKey: UserDefaultsConfiguration.Keys.isLoggedIn) }
        set {
            defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.isLoggedIn)
            AppState.shared.isLoggedIn = newValue // TODO: 다른 반응형 프레임워크로 환경객체 접근하는 방안 모색 필요
            WidgetCenter.shared.reloadTimelines(ofKind: "CalendarWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "TodoListWidget")
        }
    }
    
    private(set) var appleUserEmails: [String: String] {
        get { defaults.dictionary(forKey: UserDefaultsConfiguration.Keys.appleUserEmails) as? [String: String] ?? [:] }
        set { defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.appleUserEmails) }
    }
    
    private(set) var currentUserId: String? {
        get { defaults.string(forKey: UserDefaultsConfiguration.Keys.currentUserId) }
        set { defaults.set(newValue, forKey: UserDefaultsConfiguration.Keys.currentUserId) }
    }
    
    /// UserDefaults는 직접적으로 커스텀 타입 저장이 불가함 -> JSON 형태로 변환하여 Data 타입으로 저장 및 읽어와야함.
    private(set) var dailyStats: [DailyStat]? {
        get {
            guard let data = defaults.data(forKey: UserDefaultsConfiguration.Keys.dailyStats) else { return nil }
            return try? JSONDecoder().decode([DailyStat].self, from: data)
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(data, forKey: UserDefaultsConfiguration.Keys.dailyStats)
        }
    }
    
    // MARK: - Methods
    func saveAppleUserEmail(_ email: String, for userId: String) {
        appleUserEmails[userId] = email
    }
    
    func saveDailyStats(_ _dailyStats: [DailyStat]) {
        dailyStats = _dailyStats
    }
    
    func getAppleUserEmail(for userId: String) -> String? {
        return appleUserEmails[userId]
    }
    
    /// - UserDefaults 업데이트 -> AppState의 isLoggedIn 업데이트 -> UI 자동 갱신
    func login(_ userId: String) {
        currentUserId = userId
        isLoggedIn = true
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
