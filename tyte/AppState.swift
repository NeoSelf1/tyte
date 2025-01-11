import Foundation

/// 앱의 전역 상태를 관리하는 환경 객체(Environment Object) 클래스입니다.
///
/// `AppState`는 다음과 같은 기능을 제공합니다:
/// - 사용자의 로그인 상태 관리
/// - 게스트 모드 상태 관리
///
/// ## 사용 예시
/// ```swift
/// // 앱 진입점에서 AppState 주입
/// @main
/// struct TyteApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environmentObject(AppState.shared)
///         }
///     }
/// }
///
/// // View에서 AppState 사용
/// struct ContentView: View {
///     @EnvironmentObject var appState: AppState
///
///     var body: some View {
///         if appState.isLoggedIn {
///             MainTabView()
///         } else {
///             OnboardingView()
///         }
///     }
/// }
/// ```
///
/// ## 주요 구성요소
/// ### 싱글톤 접근
/// - ``shared``
///
/// ### 상태 속성
/// - ``isLoggedIn``: 사용자의 로그인 상태를 나타냅니다
/// - ``isGuestMode``: 게스트 모드 활성화 여부를 나타냅니다
///
/// - Important: 이 클래스는 싱글톤으로 설계되었으며, SwiftUI의 환경 객체로 사용됩니다.
/// - Note: 상태 변경은 자동으로 연결된 모든 뷰의 업데이트를 트리거합니다.
/// - Warning: UserDefaultsManager를 접근해 초기 로그인 여부를 파악하고 있습니다.

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaultsManager.shared.isLoggedIn
    @Published var isGuestMode: Bool = false
    
    static let shared = AppState()
    
    private init() {}
}
