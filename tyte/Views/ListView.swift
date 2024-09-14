//
//  ListView.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    
    var body: some View {
        VStack (spacing:0){
            HStack {
                Text("일간 Todo")
                    .font(._headline2)
                    .foregroundColor(.gray90)
                
                Spacer()
                
                NavigationLink(destination: TagEditView()) {
                    Image(systemName: "tag.fill")
                        .resizable()
                        .frame(width: 24,height:24)
                        .foregroundColor(.gray90)
                        .padding(12)
                }
            }
            .frame(height:56)
            .padding(.horizontal)
            
                WeeklyCalendar(
                    selectedDate: $viewModel.selectedDate,
                    currentMonth:$viewModel.currentMonth,
                    dailyStats:viewModel.dailyStats
                )
            
            Spacer().frame(height:16)
            
            ScrollView {
                if let index = viewModel.dailyStats.firstIndex(where: {
                    viewModel.selectedDate.apiFormat == $0.date
                }){
                    StatusBoxContent(balanceData:viewModel.dailyStats[index].balanceData)
                }
                Spacer().frame(height:16)
                
                if (viewModel.todosForDate.count>0){
                    TodoListContent(isHome: false, selectedTags: Binding.constant(["tag1"]))
                    .onAppear {
                        viewModel.fetchAllDailyStats()
                        viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        viewModel.fetchAllDailyStats()
                        viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)
                    }
                } else {
                    HStack{
                        Spacer()
                        
                        Text("Todo가 없어요")
                            .font(._subhead1)
                            .foregroundColor(.gray50)
                            .padding()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .scrollIndicators(.hidden)
            .background(.gray10)
        }
        .background(.gray00)
    }
}

#Preview {
    ListView()
}
