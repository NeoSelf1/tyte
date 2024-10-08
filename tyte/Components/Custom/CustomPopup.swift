//
//  CustomPopup.swift
//  tyte
//
//  Created by 김 형석 on 9/20/24.
//

import SwiftUI

struct CustomPopup: View {
    let popup: PopupType
    
    var body: some View {
        HStack (spacing:8){
            Image(systemName: popup.icon)
                .font(._subhead1)
                .foregroundStyle(.blue30)
            
            Text(popup.text)
                .font(._subhead2)
        }
        .frame(width: 300,alignment: .leading)
        .padding()
        .background(.gray10)
        .foregroundColor(.gray60)
        .cornerRadius(8)
        .shadow(color: .gray60.opacity(0.2), radius: 16)
    }
}
