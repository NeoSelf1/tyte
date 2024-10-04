import SwiftUI
import GoogleSignIn

// 앱의 전체 클래스를 도입하여 앱의 전체 상태를 관리
// 로그인 여부, 게스트모드 여부에 따라 접근가능한 화면에 제한두기 위해 ObservableObject 프로토콜 채택하여, SwiftUI 반응형 시스템과 통합.
class AppState: ObservableObject {
    static let shared = AppState() // 전역적으로 접근 가능한 인스턴스 생성. 이는 싱글톤으로 구현되어있는 APIManager에서 appState를 직접 접근하게 하기 위해서임.
    @Published var isLoggedIn: Bool = false // Published 래퍼를 통해 상태 변화를 SwiftUI 뷰에 자동반영
    @Published var isGuestMode: Bool = false
    
    private init() {}
}


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

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
