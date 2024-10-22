import SwiftUI
import GoogleSignIn

@main
struct tyteApp: App {
    @StateObject private var appState = AppState.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState) // 싱글톤 특성을 유지하면서도, SwiftUI의 환경객체 시스템 사용 -> 앱 전역에서 동일한 isLoggedIn, isGuestMode 변수값 공유
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if error != nil || user == nil {
                            appState.isLoggedIn = false
                        } else {
                            appState.isLoggedIn = true
                        }
                    }
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isLoggedIn || appState.isGuestMode { // 게스트모드일 때에도 부분적으로 MainTabView 접근할 수 있도록 조건 추가
            MainTabView()
        } else {
            OnboardingView()
                .ignoresSafeArea()
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
