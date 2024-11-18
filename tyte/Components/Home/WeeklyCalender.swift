import SwiftUI

struct MonthlyCalendar: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isShowingMonthPicker: Bool
    
    var currentMonth: Date = Date().koreanDate.startOfMonth
    
    @State private var isLoading: Bool = false
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
        .frame(height:80)
    }
    
    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dailyStat = viewModel.weekCalendarData.first{$0.date == date.apiFormat}
        
        return(
            DayView(dailyStat: dailyStat ?? nil, date: date, isSelected: isSelected, isToday: isToday,isDayVisible:true,size: 64)
                .onTapGesture {
                    withAnimation(.mediumEaseOut) {
                        viewModel.selectedDate = date
                    }
                }
        )
    }
    
    private func daysInMonth() -> [Date] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedDate)),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart),
              let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth)
        else {
            return []
        }
        
        var date = monthStart
        var dates = [Date]()
        
        while date <= monthEnd {
            dates.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        return dates
    }
}

extension Calendar {
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [Date]()
        dates.append(dateInterval.start)
        
        enumerateDates(startingAfter: dateInterval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < dateInterval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}
