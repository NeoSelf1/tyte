//
//  MyPageView.swift
//  tyte
//
//  Created by 김 형석 on 9/14/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var viewModel: MyPageViewModel
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(Date().formattedMonth)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            
            GraphView()
                .onChange(of: viewModel.isLoaded){
                    viewModel.animateGraph()
                }

            Spacer()
        }
        
    }
}

#Preview {
    MyPageView()
        .environmentObject(MyPageViewModel())
}
