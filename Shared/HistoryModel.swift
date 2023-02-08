//
//  HistoryModel.swift
//  Calculator
//
//  Created by Changyeol Seo on 2021/11/11.
//

import Foundation
import RealmSwift
import SwiftUI

class HistoryModel : Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id:ObjectId
    @Persisted var value:String = ""
    @Persisted var date:Date = Date()
    @Persisted var memo:String = ""

    
    struct ThreadSafeModel:Hashable {
        static func == (lhs: HistoryModel.ThreadSafeModel, rhs: HistoryModel.ThreadSafeModel) -> Bool {
            return lhs.id == rhs.id && lhs.value == rhs.value && lhs.memo == rhs.memo && lhs.date == rhs.date
        }
        let id:ObjectId
        let value:String
        let memo:String
        let date:Date
        
        var isMemoEmpty:Bool {
            memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        public func copyToPastboard()->String {
            let newStr = value.replacingOccurrences(of: "`✕`", with: "*")
                .replacingOccurrences(of: "`÷`", with: "/")
                .replacingOccurrences(of: "`-`", with: "-")
                .replacingOccurrences(of: "`+`", with: "+")
                .replacingOccurrences(of: "`=`", with: "=")
                .replacingOccurrences(of: "**", with: "")
            #if FULL
            UIPasteboard.general.string = newStr
            #endif
            return newStr
        }
    }
    
    var threadSafeModel:ThreadSafeModel {
        return .init(id:id, value: value, memo: memo, date: date)
    }
}
