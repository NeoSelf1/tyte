import SwiftUI

struct CalenderView: View {
    @EnvironmentObject var viewModel: MyPageViewModel
    private let dayViewSize:CGFloat = 48
    
    var body: some View {
        VStack {
            headerView
            calendarGridView
        }
        .padding(.horizontal)
        .padding(.bottom,24)
    }
    
    // MARK: - 헤더 뷰
    private var headerView: some View {
        VStack {
            yearMonthView
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                ForEach(Self.weekdaySymbols.indices, id: \.self) { symbol in
                    Text(Self.weekdaySymbols[symbol].uppercased())
                        .font(._body3)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - 연월 표시
    private var yearMonthView: some View {
        HStack(alignment: .center, spacing: 32) {
            Button(
                action: {
                    changeMonth(by: -1)
                },
                label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 16)
                        .font(.title)
                        .foregroundColor(canMoveToPreviousMonth() ? .black : . gray)
                }
            )
            .padding(.horizontal)
            .padding(.vertical,6)
            .disabled(!canMoveToPreviousMonth())
            
            Text(viewModel.currentMonth.formattedMonth)
                .font(._subhead1)
                .foregroundStyle(.gray90)
            
            Button(
                action: {
                    changeMonth(by: 1)
                },
                label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 10, height: 16)
                        .font(.title)
                        .foregroundColor(canMoveToNextMonth() ? .black : .gray)
                }
            )
            .padding(.horizontal)
            .padding(.vertical,6)
            .disabled(!canMoveToNextMonth())
        }
    }
    
    // MARK: - 날짜 그리드 뷰
    private var calendarGridView: some View {
        let daysInMonth: Int = numberOfDays(in: viewModel.currentMonth)
        let firstWeekday: Int = firstWeekdayOfMonth(in: viewModel.currentMonth) - 1
        let lastDayOfMonthBefore = numberOfDays(in: previousMonth())
        let numberOfRows = Int(ceil(Double(daysInMonth + firstWeekday) / 7.0))
        let visibleDaysOfNextMonth = numberOfRows * 7 - (daysInMonth + firstWeekday)
        
        
        return LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(-firstWeekday ..< daysInMonth + visibleDaysOfNextMonth, id: \.self) { index in
                Group() {
                    if index > -1 && index < daysInMonth {
                        let date = getDate(for: index)
                        let isToday = date.formattedCalendarDayDate == today.formattedCalendarDayDate
                        
                        DayView(dailyStats: viewModel.calenderData, date: date, isSelected: true, isToday: isToday)
                            .frame(width: dayViewSize, height: dayViewSize, alignment: .center)
                            .onTapGesture {
                                viewModel.selectedDate = date
                            }
                    } else if let prevMonthDate = Calendar.current.date(
                        byAdding: .day,
                        value: index + lastDayOfMonthBefore,
                        to: previousMonth()
                    ) {
                        DayView(dailyStats: viewModel.calenderData, date: prevMonthDate, isSelected: false, isToday: false)
                            .frame(width: dayViewSize, height: dayViewSize, alignment: .center)
                    }
                }
                .onTapGesture {
                    if 0 <= index && index < daysInMonth {
                        let date = getDate(for: index)
                        viewModel.selectedDate = date
                    }
                }
            }
        }
    }
}
// MARK: -

private extension CalenderView {
  var today: Date {
    let now = Date()
    let components = Calendar.current.dateComponents([.year, .month, .day], from: now)
    return Calendar.current.date(from: components)!
  }
  
  static let weekdaySymbols: [String] = Calendar.current.shortWeekdaySymbols
}

private extension CalenderView {
  /// 특정 해당 날짜
  func getDate(for index: Int) -> Date {
    let calendar = Calendar.current
    guard let firstDayOfMonth = calendar.date(
      from: DateComponents(
        year: calendar.component(.year, from: viewModel.currentMonth),
        month: calendar.component(.month, from: viewModel.currentMonth),
        day: 1
      )
    ) else {
      return Date()
    }
    
    var dateComponents = DateComponents()
    dateComponents.day = index
    
    let timeZone = TimeZone.current
    let offset = Double(timeZone.secondsFromGMT(for: firstDayOfMonth))
    dateComponents.second = Int(offset)
    
    let date = calendar.date(byAdding: dateComponents, to: firstDayOfMonth) ?? Date()
    return date
  }
  
  /// 해당 월에 존재하는 일자 수
  func numberOfDays(in date: Date) -> Int {
    return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
  }
  
  /// 해당 월의 첫 날짜가 갖는 해당 주의 몇번째 요일
  func firstWeekdayOfMonth(in date: Date) -> Int {
    let components = Calendar.current.dateComponents([.year, .month], from: date)
    let firstDayOfMonth = Calendar.current.date(from: components)!
    
    return Calendar.current.component(.weekday, from: firstDayOfMonth)
  }
  
  /// 이전 월 마지막 일자
  func previousMonth() -> Date {
    let components = Calendar.current.dateComponents([.year, .month], from: viewModel.currentMonth)
    let firstDayOfMonth = Calendar.current.date(from: components)!
    let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
    
    return previousMonth
  }
  
  /// 월 변경
  func changeMonth(by value: Int) {
      viewModel.currentMonth = adjustedMonth(by: value)
  }
  
  /// 이전 월로 이동 가능한지 확인
  func canMoveToPreviousMonth() -> Bool {
    let currentDate = Date()
    let calendar = Calendar.current
    let targetDate = calendar.date(byAdding: .month, value: -3, to: currentDate) ?? currentDate
    
    if adjustedMonth(by: -1) < targetDate {
      return false
    }
    return true
  }
  
  /// 다음 월로 이동 가능한지 확인
  func canMoveToNextMonth() -> Bool {
    let currentDate = Date()
    let calendar = Calendar.current
    let targetDate = calendar.date(byAdding: .month, value: 3, to: currentDate) ?? currentDate
    
    if adjustedMonth(by: 1) > targetDate {
      return false
    }
    return true
  }
  
  /// 변경하려는 월 반환
  func adjustedMonth(by value: Int) -> Date {
    if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: viewModel.currentMonth) {
      return newMonth
    }
    return viewModel.currentMonth
  }
}

#Preview{
    CalenderView()
        .environmentObject(MyPageViewModel())
}
