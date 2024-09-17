//
//  EnvironmentKeys.swift
//  tyte
//
//  Created by 김 형석 on 9/11/24.
//

import Foundation
import SwiftUICore

private struct HomeViewModelKey: EnvironmentKey {
    static let defaultValue = HomeViewModel()
}

private struct ListViewModelKey: EnvironmentKey {
    // EnvironmentKey 프로토콜의 필수 요구사항
    static let defaultValue = ListViewModel()
}

private struct TagEditViewModelKey: EnvironmentKey {
    static let defaultValue = TagEditViewModel()
}

private struct MyPageViewModelKey: EnvironmentKey {
    static let defaultValue = MyPageViewModel()
}

private struct AuthViewModelKey: EnvironmentKey {
    static let defaultValue = AuthViewModel()
}



extension EnvironmentValues {
    var homeViewModel: HomeViewModel {
        get { self[HomeViewModelKey.self] }
        set { self[HomeViewModelKey.self] = newValue }
    }
    
    var listViewModel: ListViewModel {
        get { self[ListViewModelKey.self] }
        set { self[ListViewModelKey.self] = newValue }
    }
    
    var tagEditViewModel: TagEditViewModel {
        get { self[TagEditViewModelKey.self] }
        set { self[TagEditViewModelKey.self] = newValue }
    }
    
    var myPageViewModel: MyPageViewModel {
        get { self[MyPageViewModelKey.self] }
        set { self[MyPageViewModelKey.self] = newValue }
    }
    
    var authViewModel: AuthViewModel {
        get { self[AuthViewModelKey.self] }
        set { self[AuthViewModelKey.self] = newValue }
    }
}
