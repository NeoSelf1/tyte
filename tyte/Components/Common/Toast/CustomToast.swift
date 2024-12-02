//
//  CustomToast.swift
//  ddom
//
//  Created by 김 형석 on 9/20/24.
//

import SwiftUI
import Foundation

struct CustomToast: View {
    let toastData: ToastData
    
    var body: some View {
        HStack (spacing:8){
            Image(systemName: toastData.type.icon)
                .font(._subhead1)
                .foregroundStyle(.blue30)
            
            Text(toastData.type.text)
                .font(._subhead2)
                .frame(maxWidth: .infinity,alignment: .leading)
            
            if let action = toastData.action {
                Button(action: action ) {
                    Text(toastData.type.button ?? "보기")
                        .font(._body4)
                        .foregroundStyle(.gray60)
                }
                .padding(.horizontal,6)
            }
        }
        .frame(width: 300,alignment: .leading)
        .padding()
        .background(.gray10)
        .foregroundColor(.gray60)
        .cornerRadius(8)
        .shadow(color: .gray60.opacity(0.2), radius: 16)
    }
}

//#Preview("Toast") {
//    CustomToast_Preview()
//}
//
//struct CustomToast_Preview: View {
//    @State private var showPopup = false
//
//    var body: some View {
//        CustomToast(toastData: ToastData(type: .friendRequested("테스트"), action: {print("heeloo")}))
//    }
//}
