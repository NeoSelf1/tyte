import Foundation

extension Date {
    private static let koreanTimeZone = TimeZone(identifier: "Asia/Seoul")!
    
    private static let sharedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = koreanTimeZone
        return formatter
    }()
    
    private func string(withFormat format: String) -> String {
        let formatter = Date.sharedFormatter
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var apiFormat: String {
        string(withFormat: "yyyy-MM-dd")
    }
    
    var formattedCalendarDayDate: String {
        string(withFormat: "MMMM yyyy dd")
    }
    
    var formattedDate: String {
        string(withFormat: "yyyy년 M월 d일")
    }
    
    var formattedMonth: String {
        string(withFormat: "yyyy년 MM월")
    }
    
    var formattedYear: String {
        string(withFormat: "yyyy년")
    }
    
    var formattedMonthDate: String {
        string(withFormat: "M월 d일")
    }
    
    var weekdayString: String {
        string(withFormat: "E")
    }
    
    var formattedDay: String {
        string(withFormat: "d")
    }
    
    var koreanDate: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Date.koreanTimeZone // Asia/Seoul로 설정
        
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var startOfMonth: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Date.koreanTimeZone
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
    }
}
