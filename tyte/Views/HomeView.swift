//
//  ListView.swift
//  tyte
//
//  Created by 김 형석 on 9/3/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState:AppState
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    
    @State private var selectedTodo: Todo?
    @State private var isShowingMonthPicker = false
    
    var body: some View {
        ZStack{
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
                        
                        if appState.isGuestMode {
                            Button{
                                withAnimation (.fastEaseOut) {
                                    appState.isLoginRequiredViewPresented = true
                                }
                            } label: {
                                Image(systemName: "tag.fill")
                                    .resizable()
                                    .frame(width: 24,height:24)
                                    .foregroundColor(.gray90)
                                    .padding(12)
                            }
                        } else {
                            NavigationLink(destination: TagEditView()) {
                                Image(systemName: "tag.fill")
                                    .resizable()
                                    .frame(width: 24,height:24)
                                    .foregroundColor(.gray90)
                                    .padding(12)
                            }
                        }
                    }
                    .frame(height:52)
                    .padding(.horizontal)
                    
                    MonthlyCalendar(
                        viewModel:viewModel,
                        isShowingMonthPicker:$isShowingMonthPicker
                    )
                    .padding(.top, -16)
                    .padding(.bottom,16)
                    .onAppear {
                        viewModel.scrollToToday(proxy: proxy)
                    }
                }
                
                Divider().frame(minHeight:3).background(.gray10)
                
                List {
                    StatusBoxContent(viewModel: viewModel)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    
                    if (viewModel.todosForDate.isEmpty){
                        Spacer()
                            .listRowInsets(EdgeInsets()) // 삽입지(외곽 하얀 여백.)
                            .listRowSeparator(.hidden) // 사이 선
                            .listRowBackground(Color.clear)
                            .padding(.top,16)
                        
                    } else {
                        ForEach(viewModel.todosForDate) { todo in
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
                                            appState.currentToast = .error("이전 투두들은 수정이 불가능해요.")
                                        } else {
                                            selectedTodo = todo
                                            viewModel.isDetailPresented = true
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
                
                .refreshable(action: { viewModel.fetchInitialData() })
                .onAppear { viewModel.fetchInitialData() }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    viewModel.fetchInitialData()
                }
            }
            
            FloatingActionButton(action: {
                if appState.isGuestMode {
                    withAnimation (.fastEaseOut) {
                        appState.isLoginRequiredViewPresented = true
                    }
                } else {
                    viewModel.isCreateTodoPresented = true
                }
            })
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .sheet(isPresented: $viewModel.isCreateTodoPresented) {
            CreateTodoView(viewModel:viewModel)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.gray00)
        }
        .background(.gray00)
        .sheet(isPresented: $viewModel.isDetailPresented) {
            if let todo = selectedTodo {
                TodoEditBottomSheet(
                    tags: viewModel.tags,
                    todo: todo,
                    onUpdate: { updatedTodo in
                        viewModel.editTodo(updatedTodo)
                        viewModel.isDetailPresented = false
                    },
                    onDelete: { id in
                        viewModel.deleteTodo(id: id)
                        viewModel.isDetailPresented = false
                    }
                )
                .onAppear{
                    viewModel.fetchTags()
                }
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
                        isShowing: $isShowingMonthPicker,
                        viewModel:viewModel
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
