//
//  MyPageView.swift
//  tyte
//
//  Created by 김 형석 on 9/14/24.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel: MyPageViewModel = MyPageViewModel()
    @StateObject private var authViewModel: AuthViewModel = AuthViewModel()
    
    var body: some View {
        VStack{
            VStack (spacing:0){
                HStack (alignment: .center){
                    Text("내 정보")
                        .font(._headline2)
                        .foregroundColor(.gray90)
                    
                    Spacer()
                        .frame(width:120)
                    
                    ViewSelector(viewModel: viewModel)
                }
                .frame(height:56)
                .padding(.horizontal)
                
                if (viewModel.currentTab == 0){
                    CalenderView(viewModel: viewModel)
                        .frame(maxHeight: 360)
                } else {
                    GraphView(viewModel: viewModel)
                        .frame(maxHeight: 360)
                }
            }.background(.gray00)
            
            Button(action: {
                authViewModel.logout()
            }) {
                Text("로그아웃")
                    .font(._body1)
                    .foregroundColor(.blue30)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue10)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .background(.gray10)
        .sheet(isPresented: $viewModel.isDetailViewPresented) {
            DetailView(viewModel: viewModel)
        }
    }
}
