//
//  EnvironmentKeys.swift
//  tyte
//
//  Created by 김 형석 on 9/17/24.
//

import Foundation
import SwiftUI

// MARK: 즉시 실행되지 않으며, 선언 시 제공된 초기화(= SharedTodoViewModel())는 인스턴스 생성이 아니라 기본값으로 취급
//MARK: 실제로 인스턴스가 생성되는 구문 @StateObject sharedTodoViewModel의 Projected 값에 접근하기에 실제 초기화를 제어

struct SharedTodoKey: EnvironmentKey {
    static let defaultValue = SharedTodoViewModel()
}

struct HomeKey: EnvironmentKey {
    static var defaultValue: HomeViewModel {
        HomeViewModel(sharedTodoVM: SharedTodoKey.defaultValue)
    }
}

struct ListKey: EnvironmentKey {
    static var defaultValue: ListViewModel {
        ListViewModel(sharedTodoVM: SharedTodoKey.defaultValue)
    }
}

extension EnvironmentValues {
    var shared: SharedTodoViewModel {
        get { self[SharedTodoKey.self] }
        set { self[SharedTodoKey.self] = newValue }
    }
    
    var home: HomeViewModel {
        get { self[HomeKey.self] }
        set { self[HomeKey.self] = newValue }
    }
    
    var list: ListViewModel {
        get { self[ListKey.self] }
        set { self[ListKey.self] = newValue }
    }
}
