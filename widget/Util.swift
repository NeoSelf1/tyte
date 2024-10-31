//
//  Util.swift
//  tyte
//
//  Created by Neoself on 10/21/24.
//

import Foundation

func getToken() -> String? {
    guard let email = UserDefaults.standard.string(forKey: "lastLoggedInEmail") else {
        return nil
    }
    
    do {
        return try KeychainManager.shared.retrieve(service: APIConstants.tokenService,account: email)
    } catch {
        print("Failed to retrieve token: \(error.localizedDescription)")
        return nil
    }
}
