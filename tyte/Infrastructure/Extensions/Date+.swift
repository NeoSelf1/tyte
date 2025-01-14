import Foundation

extension Date {
    private static let koreanTimeZone = TimeZone(identifier: "Asia/Seoul")!
    
    /// 현재 전 세계에서 가장 널리 사용되는 달력 체계로 한국 시간대와 동기화된 캘린더 객체를 생성합니다.
    private static let koreanCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = koreanTimeZone
        return calendar
    }()
    
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
    
    /// 한국 시간대 기준으로 날짜의 시작(00:00:00)을 반환합니다.
    /// - Returns: 시간 정보가 제거된 자정 기준 Date
    var koreanDate: Date {
        let components = Self.koreanCalendar.dateComponents([.year, .month, .day], from: self)
        return Self.koreanCalendar.date(from: components) ?? self
    }
}
