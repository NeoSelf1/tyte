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
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // 시스템 지역 설정에 영향받지 않도록 설정
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // GMT로 설정
        
        return dateFormatter.date(from: self)!
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
