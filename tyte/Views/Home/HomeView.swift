import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            VStack(spacing:0){
                header
                
                Divider().frame(minHeight:3).background(.gray10)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        StatusBoxContent(viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.top, 12)

                        if viewModel.todosForDate.isEmpty {
                            Spacer().padding(.top,16)

                        } else {
                            ForEach(viewModel.todosForDate) { todo in
                                TodoItemView(
                                    todo: todo,
                                    isPast: todo.deadline.parsedDate < Calendar.current.startOfDay(for: Date().koreanDate),
                                    isButtonPresent: true,
                                    onToggle:{ viewModel.toggleTodo(todo.id) },
                                    onSelect: { viewModel.selectTodo(todo) }
                                )
                                .animation(.fastEaseInOut, value: todo.isCompleted)
                            }
                        }
                    }
                }
                .background(.gray10)
                
                .refreshable(action: { viewModel.handleRefresh() } )
            }
            
            if viewModel.isLoading, !viewModel.isCreateTodoPresented {
                ProgressView()
            }
            
            floatingActionButton
            monthPicker
        }
        .sheet(isPresented: $viewModel.isCreateTodoPresented) {
            CreateTodoBottomSheet(viewModel:viewModel)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)

        }
        .sheet(isPresented: $viewModel.isDetailPresented) {
            if let todo = viewModel.selectedTodo {
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
                .presentationDetents([.height(600)])
            }
        }
    }
    
    @ViewBuilder
    private var monthPicker: some View {
        Color.black
            .opacity(viewModel.isMonthPickerPresented ? 0.3 : 0.0)
            .ignoresSafeArea()
            .animation(.spring(duration:0.1), value:viewModel.isMonthPickerPresented)
            .onTapGesture { viewModel.isMonthPickerPresented = false }
        
        MonthYearPickerPopup(
            isShowing: $viewModel.isMonthPickerPresented,
            viewModel:viewModel
        )
        .opacity(viewModel.isMonthPickerPresented ? 1 : 0)
        .offset(y: viewModel.isMonthPickerPresented ? 0 : -80)
        
        .animation(.spring(duration:0.4), value: viewModel.isMonthPickerPresented)
    }
    
    private var floatingActionButton: some View {
        Button(action: {
            if appState.isGuestMode {
                appState.showPopup(type: .loginRequired, action: {appState.changeGuestMode(false)})
            } else {
                viewModel.isCreateTodoPresented = true
            }
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.gray00)
                .frame(width: 56, height: 56)
                .background(.blue30)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    
    private var header: some View {
        ScrollViewReader { proxy in
            VStack {
                HStack {
                    Button(action: { viewModel.isMonthPickerPresented = true }
                    ) {
                        Text(viewModel.selectedDate.formattedMonth)
                            .font(._headline2)
                            .foregroundStyle(.gray90)
                        
                        Image(systemName: "chevron.down")
                            .font(._subhead2)
                            .foregroundStyle(.gray90)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { viewModel.setDateToTodayAndScrollCalendar(proxy) } // 가로 스크롤 애니메이션 위해 필요
                    }) {
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 99)
                                .stroke(.blue10, lineWidth: 1)
                        )
                        .padding(1)
                    }
                    
                    if appState.isGuestMode {
                        Button(action: { appState.showPopup(
                            type: .loginRequired,
                            action: {appState.changeGuestMode(false) }
                        )}) {
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
                    isShowingMonthPicker:$viewModel.isMonthPickerPresented
                )
                .padding(.top, -16)
            }
            .padding(.bottom,16)
            .onChange(of: viewModel.isInitialized){
                if $1 {
                    withAnimation {
                        viewModel.setDateToTodayAndScrollCalendar(proxy)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
}
