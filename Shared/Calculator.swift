//
//  Calculator.swift
//  Test
//
//  Created by Changyeol Seo on 2021/10/08.
//

import Foundation
import SwiftUI
#if FULL || MAC
import RealmSwift
#endif
extension Notification.Name {
    static let calculator_lastNumber = Notification.Name(rawValue: "calculator_lastNumber")
    static let calculator_lastOperator = Notification.Name(rawValue: "calculator_lastOperator")
    static let calculator_calculated = Notification.Name(rawValue: "calculator_calculated")
}

class Calculator {
    static let shared = Calculator()

    
    public enum OperationType : String {
        case 더하기 = "+"  
        case 곱하기 = "✕"
        case 나누기 = "÷"
        case 빼기 = "-"
        case 괄호열기 = "("
        case 괄호닫기 = ")"

        var 우선순위 : Int {
            switch self {
                case .더하기, .빼기:
                    return 0
                case .곱하기, .나누기:
                    return 1
                default:
                    return 2
            }
        }
    }
    
    public struct Operation : Hashable {
        static func == (lhs:Operation, rhs:Operation)->Bool {
            return lhs.id == rhs.id && lhs.type == rhs.type
        }
        let id = UUID().uuidString
        let type:OperationType
        
        init(rawValue:String) {
            self.type = OperationType(rawValue: rawValue)!
        }
        
        var 우선순위:Int {
            return type.우선순위
        }
        func isPriorityIsHigherThen(_ operation:Operation)->Bool {
            self.우선순위 > operation.우선순위
        }
        
        var isFourArithmeticOperations:Bool {
            switch self.type {
                case .더하기, .나누기, .곱하기, .빼기:
                    return true
                default:
                    return false
            }
        }
    }
    
    public struct Number : Hashable {
        static func == (lhs:Number, rhs:Number)->Bool {
            return lhs.id == rhs.id && lhs.strvalue == rhs.strvalue
        }
        
        let id:String = UUID().uuidString
        let strvalue:String
        var doubleVlaue:Double {
            if strvalue == "inf" {
                return 0.0
            }
            return NSString(string: strvalue).doubleValue
        }
        var formattedString:String {
            if strvalue == "inf" {
                return "무한"
            }
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
    
    public struct Result : Hashable {
        static func == (lhs:Result, rhs:Result)->Bool {
            return lhs.id == rhs.id && lhs.doubleValue == rhs.doubleValue
        }
        let id = UUID().uuidString
        let doubleValue:Double
        var formattedString:String? {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = -1
            let str = formatter.string(from: NSNumber(value: doubleValue))
            return str
        }
    }
    
    var items:[AnyHashable] = [] {
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

        for item in items {
            if let n = item as? Calculator.Number {
                txt.append(n.formattedString)
            }
            else if let r = (item as? Result)?.formattedString {
                txt.append(" `=` ")
                txt.append("**")
                txt.append(r)
                txt.append("**")
            }
            else if let op = item as? Operation {
                switch op.type {
                    case .괄호열기, .괄호닫기:
                        txt.append("\(op.type.rawValue)")
                    default:
                        txt.append(" `\(op.type.rawValue)` ")
                }
            }
        }
        if txt.isEmpty {
            return "0"
        }
        return txt
    }
    
    var normalStringForClipboardShare:String {
        return displayMarkDownString
            .replacingOccurrences(of: "`=`", with: "=")
            .replacingOccurrences(of: "`✕`", with: "*")
            .replacingOccurrences(of: "`÷`", with: "/")
            .replacingOccurrences(of: "`-`", with: "-")
            .replacingOccurrences(of: "`+`", with: "+")
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
                        case "/":
                            return "÷"
                        default:
                            return key
                    }
                }
                
                if let last = items.last as? Operation {
                    if last.type != .괄호열기 && last.type != .괄호닫기 {
                        items.removeLast()
                        items.append(Operation(rawValue: key))
                        break
                    }
                }
                
                items.append(Operation(rawValue: inputStr))
                
                
            case "=":
                if items.last is Number || (items.last as? Operation)?.type == .괄호닫기 {
                    calculate()
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
                
            case "(":
                let last = items.last
                if last is Result {
                    items.removeAll()
                }
                if last is Number {
                    return
                }
                items.append(Operation(rawValue: key))
                
            case ")":
                let last = items.last
                if let op = last as? Operation {
                    switch op.type {
                        case .괄호닫기:
                            break
                        default:
                            return
                    }
                }

                items.append(Operation(rawValue: key))
            case "ROOT":
                if let num = items.last as? Number {
                    let value = num.doubleVlaue
                    let newValue = sqrt(value)
                    let new = Number(strvalue: "\(newValue)")
                    items.removeLast()
                    items.append(new)
                }
            case "⌫":
                if items.last is Result {
                    items.removeLast()
                } else {
                    delLastNumber()
                }
            default:
                break
        }
    }
    
    func calculate() {
        // 곱하기, 나누기 주변으로 한번씩 괄호 치기
        var newItems:Array<AnyHashable> {
            var result = items
            func insertSPOP(idx:Int) {
                var ref = 0
                for i in 0...idx {
                    let c = idx - i
                    let item = result[c]
                    switch (item as? Operation)?.type {
                        case .괄호열기:
                            ref += 1
                        case .괄호닫기:
                            ref -= 1
                        default:
                            break
                    }
                    if ref == 0 {
                        if item is Number  {
                            result.insert(Operation(rawValue: "("), at: c )
                            break
                        }
                        if let op = item as? Operation {
                            switch op.type {
                                case .더하기, .빼기 :
                                    result.insert(Operation(rawValue: "("), at: c + 1)
                                default:
                                    break
                            }
                        }

                        
                    }
                }
                ref = 0
                
                for i in idx+1..<result.count {
                    let item = result[i]
                    switch (item as? Operation)?.type {
                        case .괄호열기:
                            ref += 1
                        case .괄호닫기:
                            ref -= 1
                        default:
                            break
                    }
                    if ref == 0 {
                        if item is Number {
                            result.insert(Operation(rawValue: ")"), at: i + 1)
                            break
                        }
                    }
                }
            }
                                   
            for item in result {
                if let it = item as? Operation {
                    switch it.type {
                        case .곱하기,.나누기:
                            if let newidx = result.firstIndex(of: it) {
                                insertSPOP(idx: newidx)
                            }
                        default:
                            break
                    }
                }
            }
            return result
        }
        
        var newArray:Array<AnyHashable> {
            let items = newItems
            var result = Array<AnyHashable>()
            var opStack = Stack<Operation>()
            
            func opStackOut(isAll:Bool = true) {
                if isAll {
                    while let item = opStack.pop() {
                        if item.type != .괄호열기 {
                            result.append(item)
                        }
                    }
                }
                else {
                    while let item = opStack.pop() {
                        if item.type == .괄호열기 {
                            return
                        }
                        result.append(item)
                    }
                }
            }
            
            for item in items {
                switch (item as? Operation)?.type {
                    case .괄호열기:
                        opStack.push(item as! Operation)
                    case .괄호닫기:
                        
                        opStackOut(isAll: false)
                    case .곱하기, .나누기:

                        opStack.push(item as! Operation)
                    case .빼기, .더하기:
                        let a = opStack.list.firstIndex { op in
                            op.type == .곱하기
                        } != nil
                        let b = opStack.list.firstIndex { op in
                            op.type == .나누기
                        } != nil
                        let c = opStack.list.firstIndex { op in
                            op.type == .빼기
                        } != nil
                        let d = opStack.list.firstIndex { op in
                            op.type == .더하기
                        } != nil

                        if a || b || c || d {
                            opStackOut(isAll: false)
                        }
                        opStack.push(item as! Operation)

                    default:
                        result.append(item)
                }
                #if DEBUG
                print("-------- item : \(item)")
                var printStack = ""
                var printResult = ""
                var printItems = ""
                for item in items {
                    if let it = item as? Number {
                        printItems.append(" ")
                        printItems.append(it.formattedString)
                        printItems.append(" ")
                    }
                    if let op = item as? Operation {
                        printItems.append(op.type.rawValue)
                    }
                }
                for item in opStack.list {
                    printStack.append(item.type.rawValue)
                }
                for item in result {
                    if let it = item as? Number {
                        printResult.append(" ")
                        printResult.append(it.formattedString)
                        printResult.append(" ")
                    }
                    if let op = item as? Operation {
                        printResult.append(op.type.rawValue)
                    }
                }
                print("items : \(printItems)")
                print("stack : \(printStack)")
                print("result : \(printResult)")
                print("--------")
                #endif
            }
        
            opStackOut()
            
            return result
        }
        print("----------")
        print(newArray)
        var stack2 = Stack<Any>()
        for item in newArray {
            if item is Number {
                stack2.push(item)
            }
            if let op = item as? Operation {
                if let a = stack2.pop() as? Number, let b = stack2.pop() as? Number {
                    print("\(b.formattedString) \(op) \(a.formattedString)")
                    var result:Double {
                        switch op.type {
                            case .곱하기:
                                return b.doubleVlaue * a.doubleVlaue
                            case .나누기:
                                return b.doubleVlaue / a.doubleVlaue
                            case .더하기:
                                return b.doubleVlaue + a.doubleVlaue
                            case .빼기:
                                return b.doubleVlaue - a.doubleVlaue
                            default:
                                return 0
                        }
                    }
                    
                    let num = Number(strvalue: "\(result)")
                    stack2.push(num)
                }
            }
        }
        print(stack2)
        items.append(Result(doubleValue: (stack2.top as? Number)?.doubleVlaue ?? 0.0))
        save()
    }
    
    func calculateSimple() {
        var result:Double = 0
        var oper:Operation? = nil
        print("---------------------")
        print(items)
        for item in items {
            if let number = (item as? Number)?.doubleVlaue {
                if let op = oper {
                    switch op.type {
                    case .더하기:
                        result += number
                    case .빼기:
                        result -= number
                    case .곱하기:
                        result *= number
                    case .나누기:
                        result /= number
                    default:
                            break
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
        save()
    }
    fileprivate func save() {
#if FULL || MAC
        let realm = try! Realm()
        try! realm.write {
            realm.create(HistoryModel.self, value: ["value":displayMarkDownString], update: .all)
        }
#else
        NotificationCenter.default.post(name: .calculator_calculated, object: displayMarkDownString)        
#endif
    }
    
    func delLastNumber() {
        guard let number = items.last as? Number else {
            if Calculator.shared.items.count > 0 {
                Calculator.shared.items.removeLast()
            }
            return
        }
        let str = number.strvalue
        switch str.count {
            case 1:
                Calculator.shared.items.removeLast()
            default:
                let newstr = String(str.dropLast(1))
                let new = Calculator.Number(strvalue: newstr)
                Calculator.shared.items.removeLast()
                Calculator.shared.items.append(new)
        }
    }
}
