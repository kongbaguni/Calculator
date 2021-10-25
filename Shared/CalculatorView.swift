//
//  CalculatorView.swift
//  Test (iOS)
//
//  Created by Changyeol Seo on 2021/10/22.
//

import SwiftUI
struct Item {
    let color:Color
    let value:AnyHashable
}
fileprivate let c1 = Color(white: 0.3)
fileprivate let c2 = Color.gray
fileprivate let c3 = Color.orange

fileprivate let list:[[Item]] = [
    [.init(color: c1, value: "clear"), .init(color: c1, value: "+/-"), .init(color: c1, value:"%"), .init(color: c3, value: "/")],
    [.init(color: c2, value: 7), .init(color: c2, value: 8), .init(color: c2, value:9), .init(color: c3, value: "*")],
    [.init(color: c2, value: 4), .init(color: c2, value: 5), .init(color: c2, value:6), .init(color: c3, value: "-")],
    [.init(color: c2, value: 1), .init(color: c2, value: 2), .init(color: c2, value:3), .init(color: c3, value: "+")],
    [.init(color: c2, value: 0), .init(color: c2, value: "."), .init(color: c3, value: "=")]
]

struct CalculatorView: View {
    @State var count = 0
    @State var displayText = "0"
    @State var lastOp:String? = nil
    var clearText:String {
        if Calculator.shared.items.last is Calculator.Number {
            return "C"
        }
        return "AC"
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(displayText)")
                    .font(.title)
                    .multilineTextAlignment(.trailing)
                    .padding(20)
#if MAC
                    .background(KeyEventHandling())
#endif
            }
                
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
                                RoundedRectangle(cornerRadius: 10).fill( str == lastOp ? Color.gray : color)
                                if str == "clear" {
                                    Text(clearText)
                                        .foregroundColor(.white)
                                        .padding(0.5)
                                } else {
                                    Text(str)
                                        .foregroundColor(.white)
                                        .padding(0.5)
                                }
                            }
                            .frame(width: width, height: 50, alignment: .center)

                        }
                        .buttonStyle(PlainButtonStyle())

                    }
                }
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: .calculator_lastNumber, object: nil, queue: nil) {  noti in
                displayText = Calculator.shared.displayString
                lastOp = nil
            }
            NotificationCenter.default.addObserver(forName: .calculator_lastOperator, object: nil, queue: nil) { noti in
                displayText = Calculator.shared.displayString
                lastOp = noti.object as? String
            }
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
