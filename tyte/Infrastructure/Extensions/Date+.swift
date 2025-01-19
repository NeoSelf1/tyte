import Foundation

/// 날짜 처리를 위한 Foundation.Date 확장입니다.
///
/// 다음과 같은 날짜 관련 기능을 제공합니다:
/// - API 포맷 변환
/// - 한국어 날짜 포맷팅
/// - 날짜 컴포넌트 추출
///
/// ## 사용 예시
/// ```swift
/// let date = Date()
///
/// // API 포맷
/// let apiDate = date.apiFormat  // "2024-01-20"
///
/// // 한국어 포맷
/// let formatted = date.formattedDate  // "2024년 1월 20일"
/// ```
///
/// ## 주요 프로퍼티
/// - ``apiFormat``: "YYYY-MM-DD" 형식
/// - ``formattedDate``: 전체 날짜
/// - ``formattedMonthDate``: 월/일만 포함
///
/// - Note: 모든 날짜는 한국 시간대 기준으로 처리됩니다.
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
