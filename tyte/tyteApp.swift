//
//  tyteApp.swift
//  tyte
//
//  Created by 김 형석 on 9/1/24.
//

import SwiftUI

@main
struct tyteApp: App {
    // 모든 ViewModel을 Environment에 주입
    @StateObject private var todoListViewModel = TodoListViewModel()
    @StateObject private var tagEditViewModel = TagEditViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
                    .environmentObject(todoListViewModel)
                    .environmentObject(tagEditViewModel)
                    .environmentObject(authViewModel)

            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

