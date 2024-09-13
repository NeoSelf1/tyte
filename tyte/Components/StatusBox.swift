//
//  StatusBoxContent.swift
//  tyte
//
//  Created by 김 형석 on 9/4/24.
//

import SwiftUI

struct StatusBoxContent: View {
    let balanceData:BalanceData
    
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
                
            
            VStack(alignment: .leading, spacing: 4) {
                Text(balanceData.title)
                    .font(._title)
                    .foregroundStyle(.gray90)
                Text(balanceData.message)
                    .font(._body3)
                    .foregroundStyle(.gray50)
            }
            
            Spacer()
        }
        .padding(12)
        .background(.gray00)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .gray90.opacity(0.08), radius: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.blue10, lineWidth: 1)
        )
        .padding(1)

    }
}
