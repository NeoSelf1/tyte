/// 월별 캘린더를 표시하는 위젯
///
/// 일별 생산성 데이터를 캘린더 형태로 시각화하며, 시스템 사이즈에 따라 다른 뷰를 제공합니다.
///
/// - SupportedFamilies:
///   - small: 오늘 날짜의 프리즘만 표시
///   - medium: 현재 주의 프리즘 캘린더 표시
///   - large: 현재 월의 전체 캘린더 표시
///
/// - Note: CoreData를 통해 데이터를 관리하며, 자정에 데이터가 갱신됩니다.

import WidgetKit
import SwiftUI

/// 캘린더 위젯의 데이터 제공자
///
/// TimelineProvider 프로토콜을 구현하여 위젯의 데이터를 관리합니다.
struct CalendarWidgetProvider: TimelineProvider {
    /// 위젯의 플레이스홀더 상태를 제공합니다.
    /// - Parameter context: 위젯 컨텍스트
    /// - Returns: 더미 데이터가 포함된 엔트리
    func placeholder(in context: Context) -> CalendarEntry {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        let firstDayOfMonth = calendar.date(from: components)!
        
        let numberOfDays = calendar.component(.day, from: today)
        let dates = (0..<numberOfDays).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: firstDayOfMonth)
        }
        
        let dummyStats = dates.map { date in
            return DailyStat.dummyStat
        }
        
        return CalendarEntry(date: Date(), dailyStats: dummyStats)
    }
    
    /// 위젯의 현재 상태의 스냅샷을 제공합니다.
    /// - Parameters:
    ///   - context: 위젯 컨텍스트
    ///   - completion: 스냅샷 완료 핸들러
    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        let firstDayOfMonth = calendar.date(from: components)!
        
        let numberOfDays = calendar.component(.day, from: today)
        let dates = (0..<numberOfDays).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: firstDayOfMonth)
        }
        
        let dummyStats = dates.map { date in
            return DailyStat.dummyStat
        }
        
        completion(CalendarEntry(date: Date().koreanDate, dailyStats:dummyStats))
    }
    
    /// 위젯의 시간에 따른 업데이트 타임라인을 제공합니다.
    /// - Parameters:
    ///   - context: 위젯 컨텍스트
    ///   - completion: 타임라인 생성 완료 핸들러
    /// - Note: 자정을 기준으로 데이터가 갱신됩니다.
    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> ()) {
        let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
        let yearMonth = String(Date().koreanDate.apiFormat.prefix(7))
        
        let request = DailyStatEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date BEGINSWITH %@",  yearMonth)
        
        let dailyStats:[DailyStat]
        
        if let statEntities = try? CoreDataStack.shared.context.fetch(request) {
            dailyStats = statEntities.map { entity in
                let tagStats: [TagStat] = (entity.tagStats as? Set<TagStatEntity>)?.map { tagStatEntity in
                    TagStat(
                        id: tagStatEntity.id ?? "",
                        tag: Tag(
                            id: tagStatEntity.tag?.id ?? "",
                            name: tagStatEntity.tag?.name ?? "",
                            color: tagStatEntity.tag?.color ?? "",
                            userId: tagStatEntity.tag?.userId ?? ""
                        ),
                        count: Int(tagStatEntity.count)
                    )
                } ?? []
                
                return DailyStat(
                    id: entity.id ?? "",
                    date: entity.date ?? "",
                    userId: entity.userId ?? "",
                    balanceData: BalanceData(
                        title: entity.balanceTitle ?? "",
                        message: entity.balanceMessage ?? "",
                        balanceNum: Int(entity.balanceNum)
                    ),
                    productivityNum: entity.productivityNum,
                    tagStats: tagStats,
                    center: SIMD2<Float>(entity.centerX, entity.centerY)
                )
            }
        } else {
            dailyStats = []
        }
        
        let timeline = Timeline(
            entries: [CalendarEntry(date: Date().koreanDate, dailyStats: dailyStats)],
            policy: .after(nextMidnight)
        )
        
        completion(timeline)
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let dailyStats: [DailyStat]
}

struct CalendarWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: CalendarWidgetProvider.Entry
    
    var body: some View {
        if family == .systemLarge {
            VStack(alignment:.leading, spacing:4) {
                Text(entry.date.formattedMonth)
                    .font(._headline2)
                    .foregroundStyle(.gray90)
                
                Spacer()
                
                CalendarView(
                    currentMonth: entry.date,
                    dailyStats: entry.dailyStats,
                    selectDateForInsightData: { _ in }
                )
            }
        } else if family == .systemMedium {
            VStack(alignment:.leading, spacing:4) {
                Text(entry.date.formattedMonth)
                    .font(._headline2)
                    .foregroundStyle(.gray90)
                
                weeklyCalendarView
                    .frame(maxHeight:.infinity)
            }
        } else {
            let dailyStat = entry.dailyStats.first { $0.date == entry.date.apiFormat }
            
            DayView(dailyStat: dailyStat, date: entry.date, isToday:false, isDayVisible: false, size:120)
        }
    }
    
    private var weeklyCalendarView: some View {
        let calendar = Calendar.current
        let weekDates = (0...6).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset - calendar.component(.weekday, from: entry.date) + 1, to: entry.date)
        }
        
        return VStack(spacing: 4) {
            HStack(spacing:0) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol.prefix(1))
                        .font(._caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.gray50)
                }
            }
            
            HStack(spacing:0) {
                ForEach(weekDates, id: \.self) { date in
                    let dailyStat = entry.dailyStats.first { $0.date == date.apiFormat }
                    let isToday = calendar.isDateInToday(date)
                    
                    DayView(dailyStat: dailyStat, date: date, isToday: isToday, isDayVisible: false, size:57)
                        .frame(width:46, height:42)
                }
            }
        }
    }
}

struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CalendarWidgetProvider()
        ) { entry in
            CalendarWidgetEntryView(entry: entry)
                .padding()
                .background(.gray10)
        }
        .configurationDisplayName("TyTE 캘린더")
        .description("생산성을 한눈에 확인해보세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
