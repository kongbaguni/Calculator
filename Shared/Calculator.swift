//
//  Calculator.swift
//  Test
//
//  Created by Changyeol Seo on 2021/10/08.
//

import Foundation
import SwiftUI
class Calculator {
    static let shared = Calculator()

    var items:[Any] = [] {
        didSet {
            stringValue = "\(items)"
        }
    }
    
    @State var stringValue:String = "0"
    
    func keyInput(key:String) {
        let num:Double = Double(NSString(string:key).integerValue)
        if num > 0 || key == "0" {
            if let value = items.last as? Double {
                items.removeLast()
                items.append(value * 10 + num)
            }
            else {
                items.append(num)
            }
        }
        else {
            switch (key as? String)?.uppercased() {
            case "AC","C":
                items.removeAll()
            case "CE":
                if items.last is Int {
                    items.removeLast()
                }
            case "+/-","%","/","*","-","+":
                if items.count == 0 {
                    return
                }
                if items.last is String {
                    items.removeLast()
                }
                items.append(key)
            case "=":
                var newArr:[Any] = []
                var op:[String] = []
                for item in items {
                    if let str = item as? String {
                        op.insert(str, at: 0)
                    }
                    newArr.append(item)
                    
                }
                print("--------------")
                print(newArr)
                print("--------------")
            default:
                break
            }
        }
        print(items)
    }
}
