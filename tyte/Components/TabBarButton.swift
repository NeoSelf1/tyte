//
//  TabBarButton.swift
//  tyte
//
//  Created by 김 형석 on 9/22/24.
//

import SwiftUI

struct TabBarButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width:24,height: 24)
                    .foregroundColor(isSelected ? .blue30 : .gray30)
                    .font(._body4)
                    
                Text(text)
                    .font(._caption)
                    .foregroundColor(isSelected ? .blue30 : .gray50)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
        }
    }
}
