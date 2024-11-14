//
//  MyPageView.swift
//  tyte
//
//  Created by 김 형석 on 9/14/24.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var viewModel: MyPageViewModel
    @State private var bottomSheetPosition: PresentationDetent = .height(720)
    
    init(viewModel: MyPageViewModel = MyPageViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack (spacing:0){
                    HStack (alignment: .center){
                        ViewSelector(viewModel: viewModel)
                        Spacer()
                            .frame(width:120)
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 24,height:24)
                                .foregroundColor(.gray90)
                                .padding(12)
                        }
                    }
                    .frame(height:56)
                    .padding(.horizontal)
                    
                    if (viewModel.currentTab == 0){
                        VStack(spacing: 12) {
                            HStack{
                                Text("기록이 있는 날짜를 선택하면 상세분석결과를 확인할 수 있어요")
                                    .font(._body3)
                                    .foregroundColor(.gray50)
                                Spacer()
                            }
                            .padding()
                            .background(.gray10)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            CalenderView(
                                currentMonth: $viewModel.currentMonth,
                                dailyStats:viewModel.dailyStats,
                                selectDateForInsightData:{ date in
                                    viewModel.selectDateForInsightData(date: date)
                                }
                            )
                        }
                        .frame(maxHeight: 450)
                        
                    } else {
                        GraphView(viewModel: viewModel)
                            .frame(maxHeight: 360)
                        
                    }
                    Spacer()
            }
            .background(.gray00)
            
            .sheet(isPresented: $viewModel.isDetailViewPresented) {
                MultiLayerBottomSheet(viewModel: viewModel, bottomSheetPosition: $bottomSheetPosition)
                    .presentationDetents([.height(720), .large])
                    .presentationDragIndicator(.hidden)
            }
            .onAppear{
                viewModel.fetchDailyStats()
            }
        }
    }
}
