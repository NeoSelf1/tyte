import SwiftUI
import GoogleSignIn
import Combine

@main
struct tyteApp: App {
    @StateObject private var appState = AppState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)// 앱이 포그라운드에서 실행 중일 때 URL 처리
                }
        }
    }
}

// 앱이 백그라운드 상태이거나 실행되지 않은 상태에서 URL을 통해 앱이 실행될 때
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

//MARK: - Toast, Popup 상태관리 및 온보딩 vs 메인화면 관리
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var toastManager = ToastManager.shared
    @StateObject private var popupManager = PopupManager.shared
    
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
    }
}
