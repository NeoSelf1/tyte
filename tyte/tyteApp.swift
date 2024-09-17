import SwiftUI

@main
struct tyteApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainTabView()
                    .environmentObject(authVM)
                    .environment(\.shared, SharedTodoKey.defaultValue)
                    .environment(\.home, HomeKey.defaultValue)
                    .environment(\.list, ListKey.defaultValue)
                    .environment(\.tag, TagKey.defaultValue)
                    .environment(\.myPage, MyPageKey.defaultValue)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}
