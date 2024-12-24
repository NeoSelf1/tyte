//
//  String+.swift
//  tyte
//
//  Created by 김 형석 on 9/5/24.
//

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
    
    var formattedRange: String {
        switch(self){
        case "week":
            return "1주"
        case "month":
            return "1개월"
        default:
            return "6개월"
        }
    }
    
    var buttonText: String {
        switch(self){
        case "default":
            return "마감 임박순"
        case "recent":
            return "최근 추가순"
        default:
            return "중요도순"
        }
    }
}
