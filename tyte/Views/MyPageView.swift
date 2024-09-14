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
                    viewModel.previousMonth()
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(viewModel.currentDate.formattedMonth)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    viewModel.nextMonth()
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
