import SwiftUI
import GoogleSignIn
import Combine

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
/// ### AppDelegate
/// URL 스킴 처리를 담당하는 델리게이트로, 구글 로그인 URL 처리를 하고 있습니다.
///
/// ### ContentView
/// 앱의 루트 뷰로서 다음을 관리합니다:
/// - AppState 환경객체의 isLoggedIn 상태변수에 따라 온보딩/메인 화면 전환
/// - 토스트, 팝업 메시지 표시
/// - 오프라인 상태 UI 관리
///
/// ## 화면 전환 로직
/// ```swift
/// if appState.isLoggedIn || appState.isGuestMode {
///     MainTabView()       // 로그인 또는 게스트 모드
/// } else {
///     OnboardingView()    // 미로그인 상태
/// }
/// ```
///
/// ## UI 상태 관리
/// 앱은 세 가지 타입의 글로벌 UI 상태를 관리합니다:
/// - Toast: 일시적인 알림 메시지
/// - Popup: 사용자 상호작용이 필요한 모달
/// - OfflineUI: 네트워크 연결 상태 표시
///
/// - Important: 앱 전반에 걸쳐 공유되는 환경 객체 AppState를 주입하는 코드이므로 수정에 주의가 필요합니다.
/// - Note: 소셜 로그인 완료 후 앱으로의 복귀를 위해 AppDelegate가 필요합니다.
/// - Warning: UI 상태 관리자들은 모두 SRP에 따라 여러개의 싱글톤 클래스로 분리 구현되어야합니다.

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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var popupManager = PopupManager.shared
    @StateObject private var offlineUiManager = OfflineUIManager.shared
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            if appState.isLoggedIn || appState.isGuestMode {
                MainTabView()
            } else {
                OnboardingView()
            }
            
            if viewModel.isLoading { ProgressView() }
        }
        .presentToast(
            isPresented: $toastManager.toastPresented,
            data: toastManager.currentToastData
        )
        .presentPopup(
            isPresented: $popupManager.popupPresented,
            data: popupManager.currentPopupData
        )
        .presentOfflineUI(
            isPresented: $offlineUiManager.offlineUIPresented
        )
    }
}
