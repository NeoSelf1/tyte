/// 월별 일정을 그리드 형태로 표시하는 캘린더 컴포넌트
///
/// 요일 헤더와 날짜 그리드로 구성되며, 각 날짜 셀은 DayView를 사용하여 표시됩니다.
/// 일정이 있는 날짜는 MeshGradient 효과로 시각화됩니다.
///
/// - Parameters:
///   - currentMonth: 현재 표시할 월
///   - dailyStats: 해당 월의 일별 통계 데이터
///   - selectDateForInsightData: 날짜 선택 시 호출될 콜백
///
/// - Note: MyPageView와 SocialView의 메인 컨텐츠 영역에서 사용됩니다.
import SwiftUI

struct CalendarView: View {
    let currentMonth: Date
    let dailyStats: [DailyStat]
    let selectDateForInsightData:(Date)->Void
    
    var body: some View {
        VStack {
            dayListView
            calendarGridView
        }
        .padding(.horizontal)
        .padding(.bottom,24)
    }
}

extension CalendarView {
    /// 요일 그리드 뷰
    private var dayListView: some View {
        HStack {
            ForEach(Self.weekdaySymbols.indices, id: \.self) { symbol in
                Text(Self.weekdaySymbols[symbol].uppercased())
                    .font(._body3)
                    .foregroundColor(.gray50)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// 날짜 그리드 뷰
    private var calendarGridView: some View {
        let daysInMonth: Int = numberOfDays(in: currentMonth)
        let firstWeekday: Int = firstWeekdayOfMonth(in: currentMonth) - 1
        let lastDayOfMonthBefore = numberOfDays(in: previousMonth())
        let numberOfRows = Int(ceil(Double(daysInMonth + firstWeekday) / 7.0))
        let visibleDaysOfNextMonth = numberOfRows * 7 - (daysInMonth + firstWeekday)
        
        return LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(-firstWeekday ..< daysInMonth + visibleDaysOfNextMonth, id: \.self) { index in
                Group() {
                    if index > -1 && index < daysInMonth {
                        let today = Date().koreanDate
                        let date = getDate(for: index)
                        let isToday = today.apiFormat == date.apiFormat
                        let dailyStat = dailyStats.first{ $0.date == date.apiFormat }

                        DayView(dailyStat: dailyStat, date: date, isSelected: true, isToday: isToday, isDayVisible: false,size:64)
                            .frame(height:48) // 64 사이즈의 DayView의 height를 48로 찌부시키기
                            .onTapGesture {
                                selectDateForInsightData(date)
                            }
                    } else if Calendar.current.date(
                        byAdding: .day,
                        value: index + lastDayOfMonthBefore,
                        to: previousMonth()
                    ) != nil {
                        Rectangle()
                            .foregroundStyle(Color.clear)
                    }
                }
            }
        }
    }
}


// MARK: - CalendarGridView에서 필요로 하는 연산들

private extension CalendarView {
    static let weekdaySymbols: [String] = Calendar.current.shortWeekdaySymbols
    
    private func getDate(for index: Int) -> Date {
        let calendar = Calendar.current
        guard let firstDayOfMonth = calendar.date(
            from: DateComponents(
                year: calendar.component(.year, from: currentMonth),
                month: calendar.component(.month, from: currentMonth),
                day: 1
            )
        ) else {
            return Date().koreanDate
        }
        
        var dateComponents = DateComponents()
        dateComponents.day = index
        
        let timeZone = TimeZone.current
        let offset = Double(timeZone.secondsFromGMT(for: firstDayOfMonth))
        dateComponents.second = Int(offset)
        
        let date = calendar.date(byAdding: dateComponents, to: firstDayOfMonth) ?? Date().koreanDate
        return date
    }
    
    /// 해당 월에 존재하는 일자 수
    private func numberOfDays(in date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    /// 해당 월의 첫 날짜가 갖는 해당 주의 몇번째 요일
    private func firstWeekdayOfMonth(in date: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        
        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }
    
    /// 이전 월 마지막 일자
    private func previousMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
        
        return previousMonth
    }
}
