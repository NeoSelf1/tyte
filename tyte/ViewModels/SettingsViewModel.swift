//
//  SettingsViewModel.swift
//  tyte
//
//  Created by Neoself on 10/29/24.
//

import Foundation
import Combine
import AuthenticationServices
import GoogleSignIn
import SwiftUI

class SettingsViewModel: ObservableObject {
    let appState = AppState.shared
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func deleteAccount() {
        if let userEmail = KeychainManager.shared.getUserEmail() {
            authService.deleteAccount(userEmail)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.appState.currentToast = .error(error.localizedDescription)
                    }
                } receiveValue: { [weak self] deleteResponse in
                    self?.appState.isLoggedIn = false
                }
                .store(in: &cancellables)
        }
    }
    
    func logout() {
        do {
            if let savedEmail = UserDefaults.standard.string(forKey: "lastLoggedInEmail")  {
                try KeychainManager.shared.delete(service: APIConstants.tokenService,
                                           account: savedEmail)
            }
            GIDSignIn.sharedInstance.signOut()
            UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
            appState.isLoggedIn = false
            clearAllUserData()
        } catch {
            self.appState.currentToast = .error(error.localizedDescription)
        }
    }
    
    private func clearAllUserData() {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        allKeys.forEach { key in
            if key.starts(with: "com.neox.tyte") { // 앱 관련 키에 대해서만 삭제
                defaults.removeObject(forKey: key)
            }
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: APIConstants.tokenService
        ]
        SecItemDelete(query as CFDictionary)
    }
}
