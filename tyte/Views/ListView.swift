//
//  ListView.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: ListViewModel = ListViewModel()
    
    @State private var selectedTodo: Todo?
    @State private var isBottomSheetPresented = false
    @State private var isShowingMonthPicker = false
    
    private var shouldPresentSheet: Binding<Bool> {
        Binding(
            get: { isBottomSheetPresented && selectedTodo != nil },
            set: { isBottomSheetPresented = $0 }
        )
    }
    
    var body: some View {
        VStack (spacing:0){
            ScrollViewReader { proxy in
                HStack {
                    Button(action: {
                        withAnimation (.fastEaseOut) {
                            isShowingMonthPicker.toggle()
                        }
                    }) {
                        Text(viewModel.selectedDate.formattedMonth)
                            .font(._headline2)
                            .foregroundStyle(.gray90)
                        
                        Image(systemName: "chevron.down")
                            .font(._subhead2)
                            .foregroundStyle(.gray90)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.scrollToToday(proxy: proxy)
                    } label: {
                        HStack{
                            Text("오늘")
                                .font(._subhead2)
                                .foregroundStyle(.gray90)
                            
                            Image(systemName: "arrow.counterclockwise")
                                .font(._title)
                                .foregroundStyle(.gray90)
                        }
                        .padding(.horizontal,16)
                        .padding(.vertical,8)
                        .background(.gray00)
                        .overlay(
                            RoundedRectangle(cornerRadius: 99)
                                .stroke(.blue10, lineWidth: 1)
                        )
                        .padding(1)
                    }
                    
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
                
                MonthlyCalendar(viewModel:viewModel,isShowingMonthPicker:$isShowingMonthPicker)
                    .padding(.top, -16)
                    .padding(.bottom,16)
                    .onAppear {
                        viewModel.scrollToToday(proxy: proxy)
                    }
            }
            
            
            ScrollView {
                if let index = viewModel.weekCalenderData.firstIndex(where: {
                    viewModel.selectedDate.apiFormat == $0.date
                }){
                    StatusBoxContent(balanceData:viewModel.weekCalenderData[index].balanceData)
                }
                
                if (viewModel.todosForDate.count>0){
                    ForEach(viewModel.todosForDate) { todo in
                        TodoItemView(todo: todo, isHome: false ){ _ in viewModel.toggleTodo(todo.id)}
                            .onTapGesture {
                                selectedTodo = todo
                                isBottomSheetPresented = true
                            }
                    }
                    
                    Spacer().frame(height:80)
                        .background(.gray10)
                        
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
            .onAppear {
                viewModel.fetchWeekCalenderData()
                viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.fetchWeekCalenderData()
                viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)
            }
        }
        .background(.gray00)
        .sheet(isPresented: shouldPresentSheet) {
            if let todo = selectedTodo {
                TodoEditBottomSheet(
                    tags:viewModel.tags,
                    todo: todo,
                    onUpdate: { updatedTodo in
                        viewModel.editTodo(updatedTodo)
                        isBottomSheetPresented = false
                    },
                    onDelete: { id in
                        viewModel.deleteTodo(id: id)
                        isBottomSheetPresented = false
                    }
                )
                .presentationDetents([.height(600)])
            }
        }
        .overlay(
            Group {
                if isShowingMonthPicker {
                    MonthYearPickerPopup(
                        selectedDate:$viewModel.selectedDate,
                        isShowing: $isShowingMonthPicker
                    )
                }
            }
        )
    }
}

#Preview {
    ListView()
        .environmentObject(SharedTodoViewModel())
}
