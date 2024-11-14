//
//  CustomVButton.swift
//  tyte
//
//  Created by 김 형석 on 9/25/24.
//

import SwiftUI

struct CustomButton: View {
    let action: () -> Void
    let isLoading: Bool
    let text: String
    let isDisabled: Bool
    var loadingTint: Color = .gray60
    var enabledBackgroundColor: Color = .blue30
    var disabledBackgroundColor: Color = .gray20
    var enabledForegroundColor: Color = .gray00
    var disabledForegroundColor: Color = .gray60
    var font: Font = ._body2
    var cornerRadius: CGFloat = 10
    
    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .tint(loadingTint)
                    .frame(height:56)
            } else {
                Text(text)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(font)
                    .frame(height:56)
                    .background(isDisabled ? disabledBackgroundColor : enabledBackgroundColor)
                    .foregroundColor(isDisabled ? disabledForegroundColor : enabledForegroundColor)
                    .cornerRadius(cornerRadius)
            }
        }
        .disabled(isDisabled || isLoading)
    }
}
