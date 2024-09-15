import SwiftUI

struct WeeklyCalendar: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    @State private var visibleMonth: String = ""
    
    init(
        selectedDate: Binding<Date>
    ) {
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            
            Button(action: {withAnimation {
                scrollProxy.scrollTo(0, anchor: .center)
            }}, label: {Text("Today")})
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(-4...4, id: \.self) { weekOffset in
                        weekView(for: getWeekStartDate(weekOffset: weekOffset))
                            .id(weekOffset)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        scrollProxy.scrollTo(0, anchor: .center)
                    }
                }
            }
            .simultaneousGesture(
                DragGesture()
                    .onEnded { value in
                        let weekWidth: CGFloat = 7 * (30 + 8) // 7 days * (day width + spacing)
                        let weekOffset = Int(round(value.translation.width / -weekWidth))
                        updateVisibleMonth(weekOffset: weekOffset)
                    }
            )
        }
    }
    
    private func weekView(for date: Date) -> some View {
        HStack(spacing: 8) {
            ForEach(-3...3,id:\.self) { dayOffset in
                if let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: date) {
                    dayView(for: dayDate)
                }
            }
        }
    }
    
    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        return DayView(dailyStats: viewModel.weekCalenderData, date: date, isSelected: isSelected, isToday: isToday)
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedDate = date
                }
            }
    }
    
    private func updateVisibleMonth(weekOffset: Int = 0) {
        let visibleWeekStart = getWeekStartDate(weekOffset: weekOffset)
        let middleOfWeek = calendar.date(byAdding: .day, value: 3, to: visibleWeekStart) ?? visibleWeekStart
        visibleMonth = middleOfWeek.formattedMonth
    }
    
    private func backgroundForDate(_ date: Date) -> some View {
        Group {
            if calendar.isDate(date, inSameDayAs: selectedDate) {
                Color.blue30
            } else if calendar.isDateInToday(date) {
                Color.blue10
            } else {
                Color.clear
            }
        }
    }
    
    private func getWeekStartDate(weekOffset: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return today
        }
        return calendar.date(byAdding: .weekOfYear, value: weekOffset, to: weekStart) ?? today
    }
}
