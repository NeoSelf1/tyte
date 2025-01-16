import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    // MARK: - UI State
    
    @Published var isLoading: Bool = true
    
    // MARK: - Dependencies
    
    private let authUseCase: AuthenticationUseCaseProtocol
    
    // MARK: - Private Properties
    
    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2.5"
    }
    
    // MARK: - Initialization
    
    init(authUseCase: AuthenticationUseCaseProtocol = AuthenticationUseCase()) {
        self.authUseCase = authUseCase
        
        checkAppVersion()
    }
    
    // MARK: - Public Methods
    
    func checkAppVersion() {
        Task {
            defer { isLoading = false }
            
            do {
                let (newVersion, minVersion) = try await authUseCase.checkVersion()
                handleVersionCheck(newVersion: newVersion, minVersion: minVersion)
            } catch {
                print("Version check error: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleVersionCheck(newVersion: String, minVersion: String) {
        // 앱스토어로 이동하는 action 클로저
        let moveToAppStore = {
            if let url = URL(string: "https://apps.apple.com/kr/app/tyte/id6723872988") {
                UIApplication.shared.open(url)
            }
        }
        
        // 강제 업데이트 필요한 경우
        if currentAppVersion < minVersion {
            PopupManager.shared.show(
                type: .updateMandatory,
                action: moveToAppStore
            )
        }
        // 최신 버전이 아닌 경우
        else if currentAppVersion < newVersion {
            PopupManager.shared.show(
                type: .updateOptional,
                action: moveToAppStore
            )
        }
    }
}
