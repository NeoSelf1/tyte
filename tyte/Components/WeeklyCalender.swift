import SwiftUI

struct WeeklyCalendar: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: String
    
    let dailyStats:[DailyStat]
    
    private let calendar = Calendar.current
    @State private var visibleMonth: String = ""
    
    init(
        selectedDate: Binding<Date>,
        currentMonth:Binding<String>,
        dailyStats:[DailyStat]
    ) {
        self._selectedDate = selectedDate
        self._currentMonth = currentMonth
        self.dailyStats = dailyStats
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
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
                scrollProxy.scrollTo(0, anchor: .center)
                updateVisibleMonth(weekOffset: 0)
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
            ForEach(0..<7) { dayOffset in
                if let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: date) {
                    dayView(for: dayDate)
                }
            }
        }
    }
    
    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        return VStack {
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
                    MeshGradientView(colors: [.gray50], center: [0.5,0.5], isSelected: isSelected)
                        .frame(width: 64, height: 64)
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(alignment: .top) {
                            
                            
                            
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
                }
            }
            .frame(width: 64, height: 64)
        }
        .onAppear {
            print(dailyStats.description)
            if let index = dailyStats.firstIndex(where: { date.apiFormat == $0.date }) {
                print("onAppear")
                print(dailyStats[index].tagStats)
            }
        }
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
