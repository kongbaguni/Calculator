//
//  Calculator.swift
//  Test
//
//  Created by Changyeol Seo on 2021/10/08.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let calculator_lastNumber = Notification.Name(rawValue: "calculator_lastNumber")
    static let calculator_lastOperator = Notification.Name(rawValue: "calculator_lastOperator")
}

class Calculator {
    static let shared = Calculator()
    public struct Number {
        let strvalue:String
        var doubleVlaue:Double {
            NSString(string: strvalue).doubleValue
        }
        var formattedString:String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = -1
            let str = formatter.string(from: NSNumber(value: doubleVlaue))
            return str ?? strvalue
        }
    }
    
    var items:[Any] = [] {
        didSet {
            
            if items.count == 0 || items.last is String {
               decimalLength = 0
            }
            DispatchQueue.main.async { [unowned self]in
                if items.count == 0 {
                    NotificationCenter.default.post(name: .calculator_lastNumber, object: "0")
                }
                if let number =  items.last as? Number {
                    NotificationCenter.default.post(name: .calculator_lastNumber, object: number.strvalue)
                } else {
                    NotificationCenter.default.post(name: .calculator_lastOperator, object: items.last)
                }
            }
        }
    }
    
    var displayString:AttributedString {
        var txt = ""
        for item in items {
            if let n = item as? Calculator.Number {
                txt.append(n.formattedString)
            } else if let str = item as? String {
                txt.append(" `\(str)` ")
            }
        }
        let attr = try! AttributedString(markdown: txt)
        return attr
    }
    
    
    var numbers:[Double] {
        var result:[Double] = []
        for value in items {
            if let a = value as? Double {
                result.append(a)
            }
        }
        return result
    }
    var decimalLength:Double = 0.0
    
    func keyInput(key:String) {
        
        var isOver:Bool {
            if let li = items.last as? Number {
                return li.strvalue.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "").count >= 9
            }
            return false
        }
        
        switch key.uppercased() {
        case "0","1","2","3","4","5","6","7","8","9":
            if isOver {
                return
            }
            if let li = items.last as? Number {
                let new = "\(li.strvalue)\(key)"
                items.removeLast()
                items.append(Number(strvalue: new))
            } else {
                items.append(Number(strvalue: key))
            }
            print("number input \(key)")
        case "C":
            if items.count > 0 {
                items.removeLast()
                NotificationCenter.default.post(name: .calculator_lastNumber, object: "0")
            }
        case "AC":
            items.removeAll()
            NotificationCenter.default.post(name: .calculator_lastNumber, object: "0")
        case "CE":
            if items.last is Int {
                items.removeLast()
            }
        case "+/-":
            if let li = items.last as? Number {
                var new:String = ""
                if li.strvalue.first == "-" {
                    new = li.strvalue.replacingOccurrences(of: "-", with: "")
                } else {
                    new = "-\(li.strvalue)"
                }
                items.removeLast()
                items.append(Number(strvalue: new))
            }
        case "%":
            if let li = items.last as? Number {
                let new = li.doubleVlaue / 100
                items.removeLast()
                items.append(Number(strvalue: "\(new)"))
            }
        case "/","*","-","+","✕","÷":
            if items.count == 0 {
                return
            }
            var inputStr:String {
                switch key {
                case "*" :
                    return "✕"
                default:
                    return key
                }
            }
            
            if let last = items.last as? String {
                items.removeLast()
                if last != key {
                    items.append(inputStr)
                }
            } else {
                items.append(inputStr)
            }
            
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
        case ".":
            if isOver {
                return
            }

            if let li = items.last as? Number {
                if li.strvalue.components(separatedBy: ".").count == 1 {
                    let new = "\(li.strvalue)."
                    items.removeLast()
                    items.append(Number(strvalue: new))
                }
            }
        default:
            break
        }
        print(items)
    }
}
