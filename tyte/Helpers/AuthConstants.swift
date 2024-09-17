//
//  AuthConstants.swift
//  tyte
//
//  Created by 김 형석 on 9/17/24.
//

import Foundation

struct AuthConstants {
    static let tokenService = "com.tyte.authtoken"
    
    static func tokenAccount(for email: String) -> String {
            return email
        }
}
