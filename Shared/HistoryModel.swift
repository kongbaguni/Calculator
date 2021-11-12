//
//  HistoryModel.swift
//  Calculator
//
//  Created by Changyeol Seo on 2021/11/11.
//

import Foundation
import RealmSwift
import SwiftUI

class HistoryModel : Object {
    @Persisted(primaryKey: true) var id:ObjectId
    @Persisted var value:String = ""
    @Persisted var date:Date = Date()
}
