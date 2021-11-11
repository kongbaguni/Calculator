//
//  Date+Extensions.swift
//  Calculator
//
//  Created by Changyeol Seo on 2021/11/11.
//

import Foundation
extension Date {
    var isToday:Bool {
        return formatedString(format: "yyyy MM dd") == Date().formatedString(format: "yyyy MM dd")
    }
    /** 포메팅 한 문자열 반환*/
    func formatedString(format:String)->String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
