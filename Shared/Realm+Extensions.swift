//
//  Realm+Extensions.swift
//  Calculator
//
//  Created by Changyeol Seo on 2023/07/10.
//

import Foundation
import RealmSwift

extension Realm {
    static var shared:Realm {
        let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.net.kongbaguni")!
            .appendingPathComponent("data.realm")
        let config = Realm.Configuration(fileURL: fileURL)
        return try! Realm(configuration: config)
    }
    
}
