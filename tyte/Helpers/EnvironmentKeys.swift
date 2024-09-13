//
//  EnvironmentKeys.swift
//  tyte
//
//  Created by 김 형석 on 9/11/24.
//

import Foundation
import SwiftUICore

private struct TodoViewModelKey: EnvironmentKey {
    // EnvironmentKey 프로토콜의 필수 요구사항
    static let defaultValue = TodoListViewModel()
}

private struct TagEditViewModelKey: EnvironmentKey {
    static let defaultValue = TagEditViewModel()
}

extension EnvironmentValues {
    var todoListViewModel: TodoListViewModel {
        get { self[TodoViewModelKey.self] }
        set { self[TodoViewModelKey.self] = newValue }
    }
    
    var tagEditViewModel: TagEditViewModel {
        get { self[TagEditViewModelKey.self] }
        set { self[TagEditViewModelKey.self] = newValue }
    }
}
