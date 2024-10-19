//
//  Utils.swift
//  tyte
//
//  Created by Neoself on 10/16/24.
//

import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    var yyyyMMdd: String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
}

func getTodayString() -> String {
    let today = Date()
    return today.yyyyMMdd
}
