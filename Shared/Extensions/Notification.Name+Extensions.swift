//
//  Notification.Name+Extensions.swift
//  Calculator
//
//  Created by Changyeol Seo on 2023/09/22.
//

import Foundation
extension Notification.Name {
    static let calculator_lastNumber = Notification.Name(rawValue: "calculator_lastNumber")
    static let calculator_lastOperator = Notification.Name(rawValue: "calculator_lastOperator")
    static let calculator_calculated = Notification.Name(rawValue: "calculator_calculated")
    
    static let calculator_db_updated = Notification.Name(rawValue: "calculator_db_updated")
}
