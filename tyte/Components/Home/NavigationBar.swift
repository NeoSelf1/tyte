//
//  NavigationBar.swift
//  tyte
//
//  Created by Neoself on 12/24/24.
//
import SwiftUI

struct NavigationBar: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image("arrow_left")
                    .renderingMode(.template)
                    .foregroundColor(.gray60)
                    .padding()
            }
            
            Spacer()
            
            Text(title)
                .font(._subhead1)
                .foregroundColor(.gray90)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("완료")
                    .font(._subhead2)
                    .foregroundColor(.blue30)
                    .padding()
            }
        }
        .padding(.horizontal)
    }
}
