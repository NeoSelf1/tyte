import SwiftUI
import GoogleSignIn

/// TyTE 앱의 진입점과 메인 구조를 정의하는 파일입니다.
///
/// 이 파일은 다음과 같은 주요 기능을 담당합니다:
/// - 앱의 진입점 설정 및 초기화
/// - 전역 상태 관리 설정
/// - URL 스킴 처리 (소셜 로그인)
/// - 화면 전환 및 UI 상태 관리
///
/// ## 주요 구성요소
/// ### tyteApp
/// 앱의 진입점으로, 다음 기능을 설정합니다:
/// - AppState를 통한 전역 상태 관리
/// - URL 처리를 위한 딜리게이트 설정
/// - 환경 객체 주입
///

///
///
/// - Important: 앱 전반에 걸쳐 공유되는 환경 객체 AppState를 주입하는 코드이므로 수정에 주의가 필요합니다.
/// - Note: 소셜 로그인 완료 후 앱으로의 복귀를 위해 AppDelegate가 필요합니다.
@main
struct tyteApp: App {
    @StateObject private var appState = AppState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}


/// URL 스킴 처리를 담당하는 델리게이트로, 구글 로그인 URL 처리를 하고 있습니다.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
