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

    var isMemoEmpty:Bool {
        let new = memo.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        return new.isEmpty
    }
    
    var valueWithMemo : String {
        isMemoEmpty ? value : "\(value) : \(memo)"
    }
}
