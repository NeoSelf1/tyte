import Foundation

extension String {
    var parsedDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
}
