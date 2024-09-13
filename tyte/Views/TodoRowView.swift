//
//  TodoRowView.swift
//  tyte
//
//  Created by 김 형석 on 9/1/24.
//

import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    var onToggle: () -> Void
    
    // 명시적 초기화 메서드 추가
    init(todo: Todo, onToggle: @escaping () -> Void = {}) {
        self.todo = todo
        self.onToggle = onToggle
    }
    
    var body: some View {
        
    }
}


//#Preview {
//    TodoRowView(todo: Todo(
//        id: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
//        title: "SwiftUI 학습하기",
//        priority: 2,
//        estimatedTime: 3600,
//        deadline: "2024-9-20",
//        isCompleted: false
//    ))
//}
