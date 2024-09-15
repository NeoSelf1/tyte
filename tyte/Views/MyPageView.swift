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
            Picker("", selection: $viewModel.currentTab) {
                Text("생산지수 그래프")
                    .tag("graph")
                Text("달력")
                    .tag("calender")
            }
            .pickerStyle(.segmented)
            .padding()
            if (viewModel.currentTab == "graph"){
                GraphView()
                    .onChange(of: viewModel.isLoaded){
                        viewModel.animateGraph()
                    }
            } else {
                CalenderView()
            }
            Spacer()
        }
        
    }
}

#Preview {
    MyPageView()
        .environmentObject(MyPageViewModel())
}
