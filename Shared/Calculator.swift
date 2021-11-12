//
//  Calculator.swift
//  Test
//
//  Created by Changyeol Seo on 2021/10/08.
//

import Foundation
import SwiftUI
#if FULL
import RealmSwift
#endif
extension Notification.Name {
    static let calculator_lastNumber = Notification.Name(rawValue: "calculator_lastNumber")
    static let calculator_lastOperator = Notification.Name(rawValue: "calculator_lastOperator")
}

class Calculator {
    static let shared = Calculator()

    public enum Operation : String {
        case 더하기 = "+"  
        case 곱하기 = "✕"
        case 나누기 = "÷"
        case 빼기 = "-"
        
        func isPriorityIsHigherThen(_ operation:Operation)->Bool {
            switch self {
            case .더하기, .빼기:
                return false
            default:
                switch operation {
                case .더하기, .빼기:
                    return true
                case .곱하기,.나누기:
                    return false
                }
            }
        }
    }
    
    public struct Number {
        let strvalue:String
        var doubleVlaue:Double {
            NSString(string: strvalue).doubleValue
        }
        var formattedString:String {
            let isLastDot = strvalue.last == "."
            let isLastZero = strvalue.last == "0"
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = -1
            let dotComponents = strvalue.components(separatedBy: ".")
            if isLastZero && dotComponents.count > 1 {
                let a = Number(strvalue: dotComponents.first!)
                let b = dotComponents.last!
                if let s1 = formatter.string(from: NSNumber(value: a.doubleVlaue)) {
                    return "\(s1).\(b)"
                }
            }
            if let str = formatter.string(from: NSNumber(value: doubleVlaue)) {
                if isLastDot {
                    return "\(str)`.`"
                }
                return str
            }
            return strvalue
        }
    }
    
    public struct Result {
        let doubleValue:Double
        var formattedString:String? {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = -1
            let str = formatter.string(from: NSNumber(value: doubleValue))
            return str
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
    
    var displayMarkDownString:String {
        var txt = ""
        var lastOperation:Operation? = nil
        for item in items {
            if let n = item as? Calculator.Number {
                txt.append(n.formattedString)
            }
            else if let r = (item as? Result)?.formattedString {
                txt.append(" `=` ")
                txt.append(r)
            }
            else if let op = item as? Operation {
                if let lop = lastOperation {
                    if op.isPriorityIsHigherThen(lop) {
                        txt = "(\(txt))"
                    }
                }
                txt.append(" `\(op.rawValue)` ")
                lastOperation = op
            }
        }
        if txt.isEmpty {
            return "0"
        }
        return txt
    }
    
    var displayAttributedString:AttributedString {
        let attr = try! AttributedString(markdown:displayMarkDownString)
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
            if items.last is Result {
                items.removeAll()
            }
            
            if let li = items.last as? Number {
                let new = "\(li.strvalue)\(key)"
                items.removeLast()
                if li.doubleVlaue == 0 && key == "0" && li.strvalue.components(separatedBy: ".").count == 1 {
                    items.append(Number(strvalue: key))
                } else {
                    items.append(Number(strvalue: new))
                }
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
            if items.last is Result {
                return
            }
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
            
            if let last = items.last as? Operation {
                items.removeLast()
                if last.rawValue != key {
                    items.append(Operation(rawValue: key)!)
                }
            } else {
                items.append(Operation(rawValue: inputStr)!)
            }
            
        case "=":
            if items.last is Number {
                calculateSimple()
            }
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
    }
    
    
    func calculateSimple() {
        var result:Double = 0
        var oper:Operation? = nil
        print("---------------------")
        print(items)
        for item in items {
            if let number = (item as? Number)?.doubleVlaue {
                if let op = oper {
                    switch op {
                    case .더하기:
                        result += number
                    case .빼기:
                        result -= number
                    case .곱하기:
                        result *= number
                    case .나누기:
                        result /= number
                    }
                    oper = nil
                } else {
                    result = number
                }
                
            }
            if let op = item as? Operation {
                oper = op
            }
        }
        items.append(Result(doubleValue: result))
        #if FULL
        save()
        #endif
    }
    fileprivate func save() {
#if FULL
        let realm = try! Realm()
        try! realm.write {
            realm.create(HistoryModel.self, value: ["value":displayMarkDownString], update: .all)
        }
#endif
    }
}
