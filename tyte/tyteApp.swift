import SwiftUI
import GoogleSignIn

// 앱의 전체 클래스를 도입하여 앱의 전체 상태를 관리 -> AuthViewModel을 환경 객체로 주입
//class AppState: ObservableObject {
//    @Published var authViewModel: AuthViewModel
//    
//    init(authService: AuthService = AuthService()) {
//        self.authViewModel = AuthViewModel(authService: authService)
//    }
//}


@main
struct tyteApp: App {
//    @StateObject private var appState = AppState()
    
    @StateObject private var authVM = AuthViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if error != nil || user == nil {
                            authVM.isLoggedIn = false
                        } else {
                            authVM.isLoggedIn = true
                        }
                    }
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
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
