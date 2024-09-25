//
//  EmptyStateBox.swift
//  tyte
//
//  Created by 김 형석 on 9/25/24.
//

import SwiftUI

struct EmptyStateBox: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("할 일이 없습니다.")
                .font(._subhead1)
                .foregroundColor(.gray60)
            
            Text("아래 + 버튼을 눌러 새로운 할 일을 추가해보세요.")
                .font(._body2)
                .foregroundColor(.gray50)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
}
