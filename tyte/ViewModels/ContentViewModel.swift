//
//  ContentViewModel.swift
//  tyte
//
//  Created by Neoself on 12/6/24.
//
import Foundation
import Combine
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    
    private var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        checkAppVersion()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func checkAppVersion() {
        authService.checkVersion()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] versionResponse in
                guard let self = self else { return }
                // 강제 업데이트 필요한 경우
                if self.currentAppVersion < versionResponse.minVersion {
                    PopupManager.shared.show(
                        type: .updateMandatory,
                        action: {
                            if let url = URL(string: "https://apps.apple.com/kr/app/tyte/id6723872988") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                // 최신 버전이 아닌 경우
                } else if self.currentAppVersion < versionResponse.newVersion {
                    PopupManager.shared.show(
                        type: .updateOptional,
                        action: {
                            if let url = URL(string: "https://apps.apple.com/kr/app/tyte/id6723872988") {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                }
            }
            .store(in: &cancellables)
    }
}
