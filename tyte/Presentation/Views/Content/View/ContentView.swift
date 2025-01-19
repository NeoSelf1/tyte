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
/// - Warning: UI 상태 관리자들은 모두 SRP에 따라 여러개의 싱글톤 클래스로 분리 구현되어야합니다.
import SwiftUI

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
