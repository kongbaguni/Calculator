//
//  CalculatorView.swift
//  Test (iOS)
//
//  Created by Changyeol Seo on 2021/10/22.
//

import SwiftUI
#if FULL
import RealmSwift
import RxRealm
import RxSwift
#endif

struct Item {
    let color:Color
    let value:AnyHashable
}
fileprivate let c1 = Color.btn1
fileprivate let c2 = Color.btn2
fileprivate let c3 = Color.btn3

fileprivate let list:[[Item]] = [
    [.init(color: c1, value: "clear"), .init(color: c1, value: "+/-"), .init(color: c1, value:"%"), .init(color: c3, value: "÷")],
    [.init(color: c2, value: 7), .init(color: c2, value: 8), .init(color: c2, value:9), .init(color: c3, value: "✕")],
    [.init(color: c2, value: 4), .init(color: c2, value: 5), .init(color: c2, value:6), .init(color: c3, value: "-")],
    [.init(color: c2, value: 1), .init(color: c2, value: 2), .init(color: c2, value:3), .init(color: c3, value: "+")],
    [.init(color: c2, value: 0), .init(color: c2, value: "."), .init(color: c3, value: "=")],
]

struct CalculatorView: View {
    @State var count = 0
    @State var displayText:AttributedString = "0"
    @State var lastOp:String? = nil
    @State var history:[String] = []
    @State var isNeedMoreHistory:Bool = false
    #if FULL
    let disposeBag = DisposeBag()
    #endif
    
    var clearText:String {
        if Calculator.shared.items.last is Calculator.Number {
            return "C"
        }
        return "AC"
    }
    
    var body: some View {
        VStack {
            if history.count > 0 {
                List {
                    ForEach(history, id: \.self) { text in
                        let vstack =  VStack {
                            Text(try! AttributedString(markdown:text))
                                .foregroundColor(Color.gray)
                        }
#if MAC
                        vstack
#else
                        vstack.listRowSeparator(.hidden)
#endif
                    }
                }
                .background(Color.bg3)
                .listStyle(SidebarListStyle())
                .frame(minWidth: 400, idealWidth: 400, maxWidth: CGFloat.greatestFiniteMagnitude, minHeight: 100, idealHeight: 100, maxHeight: CGFloat.greatestFiniteMagnitude, alignment: .center)
            }
            else {
                Spacer().background(Color.bg3)
            }

            HStack {
                Spacer()
                Text(displayText)
                    .foregroundColor(Color.btnTextColor)
                    .font(.title)
                    .multilineTextAlignment(.trailing)
                    .padding(20)
#if MAC
                    .background(KeyEventHandling())
#endif
            }
            .background(Color.bg2)
            
            
            Spacer().frame(width: 300, height: 20, alignment: .center)
            ForEach(0..<list.count) { i in
                HStack {
                    ForEach(0..<list[i].count) { a in
                        let item = list[i][a]
                        let str = item.value as? String ?? "\(item.value as! Int)"
                        let width:CGFloat = item.value as? Int == 0 ? 110 : 50
                        let color = item.color
                        
                        Button {
                            if str == "clear" {
                                Calculator.shared.keyInput(key: clearText)
                            } else {
                                Calculator.shared.keyInput(key: str)
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill( str == lastOp ? Color.btnSelectedColor : color)
                                if str == "clear" {
                                    Text(try! AttributedString(markdown: "`\(clearText)`"))
                                        .foregroundColor(Color.btnTextColor)
                                        .padding(0.5)
                                } else {
                                    Text(try! AttributedString(markdown: "`\(str)`"))
                                        .foregroundColor(Color.btnTextColor)
                                        .padding(0.5)
                                }
                            }
                            .frame(width: width, height: 50, alignment: .center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.btnTextColor, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                }
            }
            Spacer().frame(width: 300, height: 20, alignment: .center)
            
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .calculator_lastNumber, object: nil, queue: nil) {  noti in
                displayText = Calculator.shared.displayAttributedString
                lastOp = nil
            }
            
            NotificationCenter.default.addObserver(forName: .calculator_lastOperator, object: nil, queue: nil) { noti in
                displayText = Calculator.shared.displayAttributedString
                if let op = noti.object as? Calculator.Operation {
                    lastOp = op.rawValue
                }
            }
            #if FULL
            Observable.collection(from: try! Realm().objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: false))
                .subscribe { event in
                    switch event {
                    case .next(let list):
                        isNeedMoreHistory = list.count > 5
                        var results:[String] = []
                        for item in list {
                            if results.count == 5 {
                                continue
                            }
                            results.append(item.value)
                        }
                        history = results
                        print(results)
                    default:
                        break
                    }
                    
                }.disposed(by: self.disposeBag)
            #endif
            
        }
        .background(Color.bg1)
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
