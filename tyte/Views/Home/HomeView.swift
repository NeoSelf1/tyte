import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    @StateObject private var viewModel: HomeViewModel
    @State private var isShowingMonthPicker = false
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack{
            VStack (spacing:0){
                header
                Divider().frame(minHeight:3).background(.gray10)
                
                List {
                    StatusBoxContent(viewModel: viewModel)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    
                    if (viewModel.todosForDate.isEmpty){
                        Spacer()
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
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
                                            appState.showToast(.invalidTodoEdit)
                                        } else {
                                            viewModel.selectTodo(todo)
                                        }
                                    }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .padding(.top,16)
                            .opacity(!isPast && !todo.isCompleted ? 1.0 : 0.6)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                .refreshable(action: { viewModel.fetchInitialData() })
                .onAppear { viewModel.fetchInitialData() }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    viewModel.fetchInitialData()
                }
            }
            .background(.gray10)
            
            floatingActionButton
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
            Color.black
                .opacity(isShowingMonthPicker ? 0.3 : 0.0)
                .ignoresSafeArea()
                .animation(.spring(duration:0.1),value:isShowingMonthPicker)
                .onTapGesture { isShowingMonthPicker = false }
            
            MonthYearPickerPopup(
                isShowing: $isShowingMonthPicker,
                viewModel:viewModel
            )
            .opacity(isShowingMonthPicker ? 1 : 0)
            .offset(y: isShowingMonthPicker ? 0 : -80)
            .animation(.spring(duration:0.3),value:isShowingMonthPicker)
        }
        
        .sheet(isPresented: $viewModel.isCreateTodoPresented) {
            CreateTodoBottomSheet(viewModel:viewModel)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.gray00)
        }
        .sheet(isPresented: $viewModel.isDetailPresented) {
            if let todo = viewModel.selectedTodo{
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
    }
    
    private var header: some View {
        ScrollViewReader { proxy in
            HStack {
                Button(action: {
                    isShowingMonthPicker = true
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
                isShowingMonthPicker:$isShowingMonthPicker
            )
            .padding(.top, -16)
            .padding(.bottom,16)
            .onAppear { viewModel.scrollToToday(proxy: proxy) }
        }
    }
}
