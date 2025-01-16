import Foundation
import GoogleSignIn
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Dependencies
    
    private let authUseCase: AuthenticationUseCaseProtocol
    
    // MARK: - Initialization
    
    init(authUseCase: AuthenticationUseCaseProtocol = AuthenticationUseCase()) {
        self.authUseCase = authUseCase
    }
    
    // MARK: - Public Methods
    
    /// 계정 삭제를 처리합니다.
    /// - Note: 계정 삭제는 서버에서의 데이터 삭제와 로컬 데이터 정리를 모두 포함합니다.
    func deleteAccount() {
        Task {
            do {
                try await authUseCase.deleteAccount()
                logout()
            } catch {
                print("Account deletion error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
    
    /// 로그아웃을 처리합니다.
    /// - Note: 소셜 로그인의 경우 해당 서비스의 로그아웃도 처리합니다.
    func logout() {
        // Google 로그인 상태 해제
        GIDSignIn.sharedInstance.signOut()
        // 로컬 데이터 정리
        UserDefaultsManager.shared.logout()
    }
    
    /// 다크 모드 설정을 변경합니다.
    /// - Parameter isDarkMode: 다크 모드 활성화 여부
    func setDarkMode(_ isDarkMode: Bool) {
        UserDefaultsManager.shared.setDarkMode(isDarkMode)
        setAppearance(isDarkMode: isDarkMode)
    }
    
    func setAppearance(isDarkMode: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        withAnimation(.mediumEaseInOut) {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
}
