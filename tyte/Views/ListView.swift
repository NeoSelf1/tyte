//
//  ListView.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var appState:AppState
    @ObservedObject var viewModel: ListViewModel
    @ObservedObject var sharedVM: SharedTodoViewModel
    
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
                        withAnimation (.bouncy) {
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
                    
                    NavigationLink(destination: TagEditView(viewModel:sharedVM)) {
                        Image(systemName: "tag.fill")
                            .resizable()
                            .frame(width: 24,height:24)
                            .foregroundColor(.gray90)
                            .padding(12)
                    }
                }
                .frame(height:52)
                .padding(.horizontal)
                
                MonthlyCalendar(viewModel:viewModel,isShowingMonthPicker:$isShowingMonthPicker)
                    .padding(.top, -16)
                    .padding(.bottom,16)
                    .onAppear {
                        viewModel.scrollToToday(proxy: proxy)
                    }
            }
            
            Divider().frame(minHeight:3).background(.gray10)
            
            List {
                StatusBoxContent(viewModel:viewModel)
                    .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                    .listRowBackground(Color.clear)
                    .padding(.horizontal)
                    .padding(.top,12)
                
                
                if (sharedVM.todosForDate.isEmpty){
                    Spacer()
                        .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                        .listRowSeparator(.hidden) // 사이 선
                        .listRowBackground(Color.clear)
                        .padding(.top,16)
                } else {
                    ForEach(sharedVM.todosForDate) { todo in
                        let isPast = todo.deadline.parsedDate < Calendar.current.startOfDay(for: Date().koreanDate)
                        HStack(spacing:12){
                            Button(action: {
                                viewModel.toggleTodo(todo.id)
                            }) {
                                Image(todo.isCompleted ? "checked" : "unchecked")
                                    .resizable()
                                    .frame(width: 40,height:40)
                                    .foregroundStyle(todo.isCompleted ? .gray50 : .gray60)
                                
                                    .animation(.fastEaseInOut, value: todo.isCompleted)
                            }
                            .padding(.leading,16)
                            
                            TodoItemView(todo: todo, isHome: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if isPast {
                                        sharedVM.currentPopup = .error("이전 투두들은 수정이 불가능해요.")
                                    } else {
                                        selectedTodo = todo
                                        isBottomSheetPresented = true
                                    }
                                }
                        }
                        .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                        .listRowSeparator(.hidden) // 사이 선
                        .listRowBackground(Color.clear)
                        .padding(.top,16)
                        .opacity(!isPast && !todo.isCompleted ? 1.0 : 0.6)
                    }
                }
            }
            .background(.gray10)
            .listStyle(PlainListStyle())
            
            .refreshable(action: {viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)})
            .onAppear {
                viewModel.fetchWeekCalendarData()
                viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.fetchWeekCalendarData()
                viewModel.fetchTodosForDate(viewModel.selectedDate.apiFormat)
            }
        }
        .background(.gray00)
        .sheet(isPresented: shouldPresentSheet) {
            if let todo = selectedTodo {
                TodoEditBottomSheet(
                    tags:sharedVM.tags,
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
            ZStack{
                if isShowingMonthPicker {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation (.fastEaseOut) {
                                isShowingMonthPicker = false
                            }
                        }
                     
                    MonthYearPickerPopup(
                        selectedDate:$viewModel.selectedDate,
                        isShowing: $isShowingMonthPicker
                    )
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
                }
            }
        )
    }
}
