//
//  StatusBoxContent.swift
//  tyte
//
//  Created by 김 형석 on 9/4/24.
//

import SwiftUI

struct StatusBoxContent: View {
    @ObservedObject var viewModel : ListViewModel
    private var balanceData:BalanceData
    
    init( viewModel: ListViewModel ) {
        self.viewModel = viewModel
        if let index = viewModel.weekCalenderData.firstIndex(where: {
            viewModel.selectedDate.apiFormat == $0.date
        }){
            balanceData = viewModel.weekCalenderData[index].balanceData
        } else {
            balanceData =
            BalanceData(
                title: "Todo가 없네요 :(",
                message: "아래 + 버튼을 눌러 Todo를 추가해주세요",
                balanceNum: 0)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                CircularProgressView(progress: Double(balanceData.balanceNum) / 100.0, color: balanceData.balanceNum.colorByBalanceData)
                    .frame(width: 64, height: 64)
                
                HStack (spacing:0) {
                    Text("\(balanceData.balanceNum)")
                        .font(._headline2)
                        .foregroundColor(balanceData.balanceNum.colorByBalanceData)
                        .contentTransition(.numericText(value: Double(balanceData.balanceNum)))
                        .animation(.snappy, value: Double(balanceData.balanceNum))
                    
                    Text("%")
                        .font(._body3)
                        .foregroundColor(balanceData.balanceNum.colorByBalanceData)
                }
            }
            .padding(.leading,4)
            
            VStack(alignment: .leading,spacing:0) {
                Text(viewModel.selectedDate.formattedDate)
                    .font(._body3)
                    .foregroundStyle(.gray90)
                    .padding(.bottom,4)
                
                Text(balanceData.title)
                    .font(._title)
                    .foregroundStyle(.gray90)
                    .padding(.bottom,2)
                
                Text(balanceData.message)
                    .font(._body3)
                    .foregroundStyle(.gray50)
            }
            Spacer()
        }
        .padding(10)
        .frame(height:96)
        .background(.gray00)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .gray90.opacity(0.08), radius: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.blue10, lineWidth: 1)
        )
        .padding(4)

    }
}
