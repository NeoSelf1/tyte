import SwiftUI

@main
struct tyteApp: App {
    @StateObject private var sharedTodoVM = SharedTodoViewModel()
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView()
                    .environmentObject(sharedTodoVM)
            } else {
                LoginView(viewModel: authVM)
                
            }
        }
    }
}
