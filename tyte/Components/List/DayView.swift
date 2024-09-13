//
//  DayView.swift
//  tyte
//
//  Created by 김 형석 on 9/13/24.
//

import SwiftUI

struct DayView: View {
    let dailyStats: [DailyStat]
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        VStack {
            ZStack {
                if let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date }) {
                    let colors = getColorsForDay(dailyStats[index])
                    MeshGradientView(colors: colors, center: dailyStats[index].center, isSelected: isSelected)
                        .frame(width: 64, height: 64)
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(alignment: .top) {
                            
                            Circle()
                                .fill(dailyStats[index].balanceData.balanceNum.colorByBalanceData)
                                .frame(width: 10, height: 10)
                                .padding(.top, 4)
                                .padding(.leading, 4)
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        Text(date.formattedDay)
                            .font(isSelected || isToday ? ._subhead2 : ._body2)
                            .padding(.bottom, 2)
                            .padding(.trailing, 2)
                            .foregroundColor(.gray90)
                            .overlay(
                                Group {
                                    if isToday {
                                        Rectangle()
                                            .fill(.gray90)
                                            .frame(height: 3)
                                            .offset(y: 0)
                                    }
                                }
                                , alignment: .bottom
                            )
                    }
                    
                } else {
                    MeshGradientView(colors: [.gray20], center: [0.5,0.5], isSelected: isSelected)
                    
                    Text(date.formattedDay)
                        .font(isSelected || isToday ? ._subhead2 : ._body2)
                        .frame(maxWidth: 64,maxHeight: 64,alignment: .bottomTrailing)
                        .padding(.bottom, 2)
                        .padding(.trailing, 2)
                        .foregroundColor(.gray90)
                        .overlay(
                            Group {
                                if isToday {
                                    Rectangle()
                                        .fill(.gray90)
                                        .frame(height: 3)
                                        .offset(y: 0)
                                }
                            }
                            , alignment: .bottom
                        )
                }
            }
            .frame(width: 64, height: 64)
        }
    }
}
