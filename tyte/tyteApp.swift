import SwiftUI

@main
struct tyteApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView()
            } else {
                LoginView(viewModel: authVM)
            }
        }
    }
}
