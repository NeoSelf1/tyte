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
    @StateObject private var listViewModel = ListViewModel()
    @StateObject private var tagEditViewModel = TagEditViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var myPageViewModel = MyPageViewModel()
    
    var body: some Scene {
        WindowGroup {
            if (authViewModel.isLoggedIn) {
                MainTabView()
                    .environmentObject(homeViewModel)
                    .environmentObject(listViewModel)
                    .environmentObject(tagEditViewModel)
                    .environmentObject(authViewModel)
                    .environmentObject(myPageViewModel)

            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

