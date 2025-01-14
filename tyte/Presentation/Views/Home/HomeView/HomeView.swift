import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                Divider().background(.gray20)
                listView
                    .refreshable(action: { viewModel.handleRefresh() })
            }
            
            if viewModel.isLoading, !viewModel.isCreateTodoPresented {
                ProgressView()
            }
            
            floatingActionButton
            monthPicker
        }
        .sheet(isPresented: $viewModel.isCreateTodoPresented) {
            CreateTodoBottomSheet(viewModel: viewModel)
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
}
    

// MARK: - Main View Components

extension HomeView {
    private var header: some View {
        ScrollViewReader { proxy in
            VStack {
                HStack {
                    monthButton
                    Spacer()
                    todayButton(proxy)
                    tagButton
                }
                .frame(height: 52)
                .padding(.horizontal)
                
                HorizontalCalendarSection(viewModel: viewModel)
                    .padding(.top, -16)
            }
            .padding(.bottom, 16)
            .onAppear {
                withAnimation { viewModel.setDateToTodayAndScrollCalendar(proxy) }
            }
        }
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                StatusBoxView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                if viewModel.todosForDate.isEmpty {
                    Spacer().padding(.top, 16)
                } else {
                    ForEach(viewModel.todosForDate) { todo in
                        TodoItem(
                            todo: todo,
                            isPast: todo.deadline.parsedDate < Calendar.current.startOfDay(for: Date().koreanDate),
                            isButtonPresent: true,
                            onToggle: { viewModel.toggleTodo(todo) },
                            onSelect: { viewModel.selectTodo(todo) }
                        )
                        .animation(.fastEaseInOut, value: todo.isCompleted)
                    }
                }
            }
        }
        .background(.gray10)
    }
    
    @ViewBuilder
    private var monthPicker: some View {
        Color.black
            .opacity(viewModel.isMonthPickerPresented ? 0.3 : 0.0)
            .ignoresSafeArea()
            .animation(.spring(duration: 0.1), value: viewModel.isMonthPickerPresented)
            .onTapGesture { viewModel.isMonthPickerPresented = false }
        
        MonthPickerView(
            isShowing: $viewModel.isMonthPickerPresented,
            onMonthSelect: viewModel.changeMonth
        )
        .opacity(viewModel.isMonthPickerPresented ? 1 : 0)
        .offset(y: viewModel.isMonthPickerPresented ? 0 : -80)
        .animation(.spring(duration: 0.4), value: viewModel.isMonthPickerPresented)
    }
    
    private var floatingActionButton: some View {
        Button(action: {
            if appState.isGuestMode {
                PopupManager.shared.show(
                    type: .loginRequired,
                    action: { appState.isGuestMode = false }
                )
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
    
    
    // MARK: - Header Components
    
    private var monthButton: some View {
        Button(action: { viewModel.isMonthPickerPresented = true }) {
            Text(viewModel.selectedDate.formattedMonth)
                .font(._headline2)
                .foregroundStyle(.gray90)
            
            Image(systemName: "chevron.down")
                .font(._subhead2)
                .foregroundStyle(.gray90)
        }
    }
    
    private func todayButton(_ proxy: ScrollViewProxy) -> some View {
        Button(action: {
            withAnimation { viewModel.setDateToTodayAndScrollCalendar(proxy) }
        }) {
            HStack {
                Text("오늘")
                    .font(._subhead2)
                    .foregroundStyle(.gray90)
                
                Image(systemName: "arrow.counterclockwise")
                    .font(._title)
                    .foregroundStyle(.gray90)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 99)
                    .stroke(.blue10, lineWidth: 1)
            )
            .padding(1)
        }
    }
    
    private var tagButton: some View {
        Group {
            if appState.isGuestMode {
                Button(action: {
                    PopupManager.shared.show(
                        type: .loginRequired,
                        action: { appState.isGuestMode = false }
                    )
                }) {
                    tagButtonContent
                }
            } else {
                NavigationLink(destination: TagEditView()) {
                    tagButtonContent
                }
            }
        }
    }
    
    private var tagButtonContent: some View {
        Image(systemName: "tag.fill")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.gray90)
            .padding(12)
    }
}


// MARK: - Calendar Components

private struct HorizontalCalendarSection: View {
    @ObservedObject var viewModel: HomeViewModel
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(daysInMonth(), id: \.self) { date in
                    dayView(for: date)
                        .id(date)
                }
            }
        }
        .frame(height: 80)
    }
    
    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dailyStat = viewModel.weekCalendarData.first { $0.date == date.apiFormat }
        
        return DayItem(
            dailyStat: dailyStat,
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            isDayVisible: true,
            size: 64
        )
        .onTapGesture {
            viewModel.selectDate(date)
        }
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedDate)),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
              let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth)
        else {
            return []
        }
        
        var dates = [Date]()
        var currentDate = monthStart
        
        while currentDate <= monthEnd {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
}


// MARK: - Month Picker Component

private struct MonthPickerView: View {
    @Binding var isShowing: Bool
    let onMonthSelect: (Int, Int) -> Void
    
    @State private var currentYear: Int
    @State private var currentMonth: Int
    
    init(isShowing: Binding<Bool>, onMonthSelect: @escaping (Int, Int) -> Void) {
        self._isShowing = isShowing
        self.onMonthSelect = onMonthSelect
        
        let calendar = Calendar.current
        self._currentYear = State(initialValue: calendar.component(.year, from: Date().koreanDate))
        self._currentMonth = State(initialValue: calendar.component(.month, from: Date().koreanDate) - 1)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            closeButton
            pickerSection
            confirmButton
        }
        .frame(width: 300)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.gray00)
        }
    }
    
    private var closeButton: some View {
        Button(action: {
            withAnimation(.fastEaseOut) { isShowing = false }
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.gray)
                .padding(8)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var pickerSection: some View {
        HStack {
            Picker("Year", selection: $currentYear) {
                ForEach(Array(1900...2100), id: \.self) { year in
                    Text(String(year))
                        .foregroundStyle(.gray60)
                        .tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .clipped()
            
            Picker("Month", selection: $currentMonth) {
                ForEach(0..<12) { month in
                    Text("\(month + 1)월")
                        .foregroundStyle(.gray60)
                        .tag(month)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 150)
            .clipped()
        }
    }
    
    private var confirmButton: some View {
        Button(action: {
            onMonthSelect(currentYear, currentMonth)
            withAnimation(.fastEaseOut) { isShowing = false }
        }) {
            Text("변경하기")
                .frame(maxWidth: .infinity)
                .font(._title)
                .padding()
                .background(.blue30)
                .foregroundStyle(.gray00)
                .cornerRadius(8)
        }
    }
}

#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @StateObject var mockViewModel: HomeViewModel = {
            let viewModel = HomeViewModel()
            viewModel.todosForDate = [.mock,.mock1,.mock2]
            viewModel.weekCalendarData = [.dummy]
            viewModel.tags = [
                Tag(id: "1", name: "업무", color: "FF6347", userId: "user1"),
                Tag(id: "2", name: "건강", color: "4169E1", userId: "user1"),
                Tag(id: "3", name: "취미", color: "32CD32", userId: "user1")
            ]
            return viewModel
        }()
        
        var body: some View {
            NavigationView {
                HomeView(viewModel: mockViewModel)
                    .environmentObject(AppState.shared)
            }
        }
    }
    return PreviewWrapper()
}
#endif
