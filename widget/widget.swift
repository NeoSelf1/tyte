import WidgetKit
import SwiftUI
import Intents
import IntentsUI
import Combine
import Alamofire

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), dailyStats: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        completion(CalendarEntry(date: Date(), dailyStats: []))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> ()) {
        Task {
            do {
                let today = Date().koreanDate
                let yearMonth = String(today.apiFormat.prefix(7))
                let dailyStats = try await fetchMonthlyStats(in: yearMonth)
                
                let timeline = Timeline(
                    entries: [CalendarEntry(date: today, dailyStats: dailyStats)],
                    policy: .never
                )
                completion(timeline)
            } catch {
                print("Error fetching calendar data: \(error)")
                let timeline = Timeline(
                    entries: [CalendarEntry(date: Date(), dailyStats: [])],
                    policy: .never
                )
                completion(timeline)
            }
        }
    }
    
    private func fetchMonthlyStats(in yearMonth: String) async throws -> [DailyStat] {
        let baseURL = APIConstants.baseUrl
        let endpoint = "/dailyStat/all/\(yearMonth)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(KeychainManager.shared.getAccessToken() ?? "")",
            "Content-Type": "application/json"
        ]

        return try await AF.request(baseURL + endpoint,
                                    method: .get,
                                    encoding: URLEncoding.queryString,
                                    headers: headers)
        .validate()
        .serializingDecodable([DailyStat].self)
        .value
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let dailyStats: [DailyStat]
}

struct CalendarWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
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
            DayView(dailyStat: dailyStat, date: entry.date, isToday:false, isDayVisible: false,size:120)
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
                    
                    DayView(dailyStat: dailyStat, date: date, isToday: isToday, isDayVisible: false,size:57)
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
            provider: Provider()
        ) { entry in
            if #available(iOS 17.0, *) {
                CalendarWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)

            } else {
                CalendarWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("TyTE 캘린더")
        .description("생산성을 한눈에 확인해보세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWidgetEntryView(
            entry: CalendarEntry(date: Date(), dailyStats: [widgetExtension.DailyStat(id: "674da47c72b4b1d254cda965", date: "2024-12-02", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "취미 탐험일", message: "새로운 취미를 찾거나 기존 취미를 즐기기 좋은 날이에요.", balanceNum: 0), productivityNum: 0.0, tagStats: [widgetExtension.TagStat(id: "674da7e0b48180f3ad1bdf7f", tag: widgetExtension._Tag(id: "67179a3bca61473203df9eb1", name: "여가", color: "FFF700", user: "66e3f76192082f0bf2b93b13"), count: 2)], center: SIMD2<Float>(0.6175094, 0.7614217)), widgetExtension.DailyStat(id: "67527d26ed8d602df79c2e3c", date: "2024-12-06", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "풍요로운 일상", message: "소소한 일상의 즐거움과 가벼운 업무로 풍요로운 하루를 만들어보세요.", balanceNum: 36), productivityNum: 32.0, tagStats: [widgetExtension.TagStat(id: "67527d6da50e8c873a46eac6", tag: widgetExtension._Tag(id: "67179a3bca61473203df9eb1", name: "여가", color: "FFF700", user: "66e3f76192082f0bf2b93b13"), count: 1)], center: SIMD2<Float>(0.45837203, 0.3835548)), widgetExtension.DailyStat(id: "675998c3116e0979e6a8050c", date: "2024-12-11", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "영감의 날", message: "주변의 아름다움을 느끼고 새로운 영감을 얻어보세요.", balanceNum: 13), productivityNum: 0.0, tagStats: [widgetExtension.TagStat(id: "67599fff92381f7a5701e825", tag: widgetExtension._Tag(id: "6740a33bdd82d006d3262a4a", name: "사이드프로젝트", color: "FFF700", user: "66e3f76192082f0bf2b93b13"), count: 1)], center: SIMD2<Float>(0.33748877, 0.44146946)), widgetExtension.DailyStat(id: "675998ab116e0979e6a8050b", date: "2024-12-12", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "취미 탐험일", message: "새로운 취미를 찾거나 기존 취미를 즐기기 좋은 날이에요.", balanceNum: 11), productivityNum: 0.0, tagStats: [widgetExtension.TagStat(id: "67599fff92381f7a5701e82b", tag: widgetExtension._Tag(id: "67179a3bca61473203df9eb1", name: "여가", color: "FFF700", user: "66e3f76192082f0bf2b93b13"), count: 3), widgetExtension.TagStat(id: "67599fff92381f7a5701e82d", tag: widgetExtension._Tag(id: "67179a3bca61473203df9eb3", name: "건강", color: "00FFFF", user: "66e3f76192082f0bf2b93b13"), count: 1)], center: SIMD2<Float>(0.23008093, 0.6800268)), widgetExtension.DailyStat(id: "6759884b116e0979e6a804e5", date: "2024-12-13", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "이상적인 하루", message: "오늘의 일정은 그야말로 이상적이에요. 무엇이 좋았는지 기록해두세요.", balanceNum: 57), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.5314015, 0.6773152)), widgetExtension.DailyStat(id: "675988dd116e0979e6a804ea", date: "2024-12-14", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "영감의 날", message: "주변의 아름다움을 느끼고 새로운 영감을 얻어보세요.", balanceNum: 19), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.22815134, 0.73034674)), widgetExtension.DailyStat(id: "6759873b116e0979e6a804e0", date: "2024-12-15", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "폭주 기관차 모드", message: "엄청난 속도로 달리고 있어요. 가끔은 속도를 늦추고 주변을 둘러보세요.", balanceNum: 95), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.38293502, 0.22535847)), widgetExtension.DailyStat(id: "675998c3116e0979e6a8050d", date: "2024-12-16", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "인생의 쉼표", message: "잠시 멈춰 서서 삶의 의미를 되새겨보는 건 어떨까요?", balanceNum: 20), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.46815914, 0.61198026)), widgetExtension.DailyStat(id: "6759877d116e0979e6a804e2", date: "2024-12-18", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "활력 충전의 날", message: "일과 삶 사이에서 활력을 되찾는 날이에요. 즐겁게 보내세요!", balanceNum: 37), productivityNum: 34.69, tagStats: [], center: SIMD2<Float>(0.6403849, 0.40513927)), widgetExtension.DailyStat(id: "67598859116e0979e6a804e6", date: "2024-12-19", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "자기 계발의 기회", message: "자기 계발에 투자할 수 있는 황금 같은 시간이에요.", balanceNum: 19), productivityNum: 17.34, tagStats: [], center: SIMD2<Float>(0.5586612, 0.5766164)), widgetExtension.DailyStat(id: "676506a40c50fc438594b03b", date: "2024-12-20", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "취미 탐험일", message: "새로운 취미를 찾거나 기존 취미를 즐기기 좋은 날이에요.", balanceNum: 0), productivityNum: 7.19, tagStats: [widgetExtension.TagStat(id: "6765218f1dbf5097ccd32182", tag: widgetExtension._Tag(id: "67179a3bca61473203df9eb1", name: "여가", color: "FFF700", user: "66e3f76192082f0bf2b93b13"), count: 2)], center: SIMD2<Float>(0.4025042, 0.6357763)), widgetExtension.DailyStat(id: "676508070c50fc438594b03f", date: "2024-12-21", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "인생의 쉼표", message: "잠시 멈춰 서서 삶의 의미를 되새겨보는 건 어떨까요?", balanceNum: 19), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.7514574, 0.61102986)), widgetExtension.DailyStat(id: "676508820c50fc438594b041", date: "2024-12-25", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "영감의 날", message: "주변의 아름다움을 느끼고 새로운 영감을 얻어보세요.", balanceNum: 19), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.32180426, 0.5453277)), widgetExtension.DailyStat(id: "675988b9116e0979e6a804e8", date: "2024-12-26", user: "66e3f76192082f0bf2b93b13", balanceData: widgetExtension.BalanceData(title: "영감의 날", message: "주변의 아름다움을 느끼고 새로운 영감을 얻어보세요.", balanceNum: 20), productivityNum: 0.0, tagStats: [], center: SIMD2<Float>(0.56953293, 0.7452581))])
        )
        .containerBackground(.gray00, for: .widget)
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
