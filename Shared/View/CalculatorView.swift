//
//  CalculatorView.swift
//  Test (iOS)
//
//  Created by Changyeol Seo on 2021/10/22.
//

import SwiftUI
#if FULL || MAC
import RealmSwift
import RxRealm
import RxSwift
#endif

struct Item {
    let color:Color
    let value:AnyHashable
    let width:CGFloat
}
fileprivate let c1 = Color.btn1
fileprivate let c2 = Color.btn2
fileprivate let c3 = Color.btn3

fileprivate let list:[[Item]] = [
    [.init(color: .yellow, value: "(", width:110), .init(color: .yellow, value: ")", width:110)],
    [.init(color: c1, value: "clear", width:50), .init(color: c1, value: "+/-",width:50), .init(color: c1, value:"%",width:50), .init(color: c3, value: "÷",width:50)],
    [.init(color: c2, value: 7, width:50), .init(color: c2, value: 8, width:50), .init(color: c2, value:9, width:50), .init(color: c3, value: "✕", width:50)],
    [.init(color: c2, value: 4, width:50), .init(color: c2, value: 5, width:50), .init(color: c2, value:6, width:50), .init(color: c3, value: "-", width:50)],
    [.init(color: c2, value: 1, width:50), .init(color: c2, value: 2, width:50), .init(color: c2, value:3, width:50), .init(color: c3, value: "+", width:50)],
    [.init(color: c2, value: 0, width:110), .init(color: c2, value: ".",width:50), .init(color: c3, value: "=",width:50)],
]

struct CalculatorView: View {
    @State var count = 0
    @State var displayText:AttributedString = "0"
    @State var lastOp:String? = nil
    @State var history:[String] = []
    @State var toastTitle:Text? = nil
    @State var toastMessage:String = ""
    @State var isToast:Bool = false
    #if FULL || MAC
    let disposeBag = DisposeBag()
    #endif
    
    var 괄호열기가능:Bool {
        let last = Calculator.shared.items.last
        let a = Calculator.shared.items.count == 0
        let b = last is Calculator.Operation
        let c = last as? Calculator.Operation == .괄호열기
        let d = Calculator.shared.items.last is Calculator.Result
        return a || b || c || d
    }
    
    var 괄호닫기가능:Bool {
        let items = Calculator.shared.items
        let last = items.last
    
        let counta = items.filter { item in
            return (item as? Calculator.Operation) == .괄호열기
        }.count
        let countb = items.filter { item in
            return (item as? Calculator.Operation) == .괄호닫기
        }.count
        
        let a = items.count > 0
        let b = last is Calculator.Number || last as? Calculator.Operation == .괄호닫기
        return a && b && counta > countb
    }
    
    var 계산가능:Bool {
        let items = Calculator.shared.items
        let last = items.last
        let a = Calculator.shared.items.count > 1
        
        let counta = items.filter { item in
            return (item as? Calculator.Operation) == .괄호열기
        }.count
        let countb = items.filter { item in
            return (item as? Calculator.Operation) == .괄호닫기
        }.count
        
        let b = last is Calculator.Number || (last as? Calculator.Operation) == .괄호닫기
        let c = counta == countb
        return a && b && c
    }
    
    var clearText:String {
        let last = Calculator.shared.items.last
        let a = last is Calculator.Number
        let b = (last as? Calculator.Operation) == .괄호닫기
        let c = (last as? Calculator.Operation) == .괄호열기
        if a || b || c {
            return "C"
        }
        return "AC"
    }
    var bannerAdView : some View {
#if !MAC && FULL
        HStack {
            Spacer()
            BannerAdView(sizeType: .GADAdSizeLargeBanner, padding: .zero)
            Spacer()
        }
#else
        EmptyView()
#endif
    }
    
    var historylistView: some View {
        Group {
            if (history.count == 0) {
                ScrollView {
                    bannerAdView
                    Text("empty history log...")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundColor(Color.btnSelectedColor)
                        .padding(50)
                }
            }
            else  {
                ScrollView {
                    bannerAdView
                    LazyVStack {
                        ForEach(0..<history.count, id : \.self) { idx in
                            let texts = history[idx].components(separatedBy: " `=` ")
                            
                            HStack {
                                Text("\(idx)")
                                    .foregroundColor(Color.idxTextColor)
                                    .font(.system(size: 20,weight: .heavy))

                                Text(try! AttributedString(markdown:texts.first!))
                                    .foregroundColor(Color.btnTextColor)
                                    .font(.system(size: 20,weight: .heavy))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text(" `=` ")
                                    .foregroundColor(Color.btnTextColor)
                                    .font(.system(size: 20,weight: .heavy))
                                
                                Button {
                                    if let txt = texts.last {
                                        let nt = txt.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: "")
                                        
                                        let number = Calculator.Number(strvalue: nt)
                                        Calculator.shared.items.removeAll()
                                        Calculator.shared.items.append(number)
                                    }
                                } label: {
                                    Text(try! AttributedString(markdown:texts.last!))
                                        .foregroundColor(Color.idxTextColor)
                                        .font(.system(size: 20,weight: .heavy))
                                }
                                Spacer()
                            }.fixedSize(horizontal: false, vertical: true)

                            .padding(10)
                        }

                    }
                }
                .background(Color.bg3)
                .listStyle(SidebarListStyle())
                .frame(minWidth: 300, idealWidth: 300, maxWidth: CGFloat.greatestFiniteMagnitude, minHeight: 100, idealHeight: 100, maxHeight: CGFloat.greatestFiniteMagnitude, alignment: .center)
            }
        }
    }
    
    var numberDisplayView : some View {
        ScrollView {
            HStack {
                Spacer()
                Text(displayText)
                    .foregroundColor(Color.btnTextColor)
                    .font(.title)
                    .multilineTextAlignment(.trailing)
                    .padding(20)
                    .fixedSize(horizontal: false, vertical: true)
#if MAC
                    .background(KeyEventHandling())
#endif
            }
        }
        .frame(height: 100)
        .background(Color.bg2)
        .onTapGesture {
            if let last = Calculator.shared.items.last as? Calculator.Number {
                let str = last.strvalue
                switch str.count {
                    case 0:
                        break
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
        .onLongPressGesture {
            #if !MAC
            let txt = Calculator.shared.normalStringForClipboardShare
            UIPasteboard.general.string = txt
            isToast = true
            toastTitle = Text("copy to clipboard")
            toastMessage = txt            
            print("longPress")
            #endif
        }

    }
    
    var buttons : some View {
        VStack {
            ForEach(0..<list.count, id:\.self) { i in
                HStack {
                    ForEach(0..<list[i].count, id:\.self) { a in
                        let item = list[i][a]
                        let str = item.value as? String ?? "\(item.value as! Int)"
                        let width:CGFloat = item.width 
                        let color = item.color
                        let isEnable = str == "(" ? 괄호열기가능 : str == ")" ? 괄호닫기가능 :  str == "=" ? 계산가능 : true
                        Button {
                            if isEnable {
                                if str == "clear" {
                                    Calculator.shared.keyInput(key: clearText)
                                } else {
                                    Calculator.shared.keyInput(key: str)
                                }
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
                        .opacity(isEnable ? 1.0 : 0.5)
                        
                    }
                }
            }
        }
    }
    var body: some View {
        GeometryReader { geomentry in
            if geomentry.size.width < geomentry.size.height {
                VStack {
                    historylistView
                    numberDisplayView
                    Spacer().frame(width: 300, height: 20, alignment: .center)
                    buttons
                    Spacer().frame(width: 300, height: 20, alignment: .center)
                }
            } else {
                HStack {
                    VStack {
                        historylistView
                        numberDisplayView
                    }
                    VStack {
                        Spacer()
                        buttons
                        Spacer()
                    }.frame(width:300)
                }
            }
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
            #if FULL || MAC
            Observable.collection(from: try! Realm().objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: false))
                .subscribe { event in
                    switch event {
                    case .next(let list):
                        var results:[String] = []
                        for item in list {
                            if results.count == 20 {
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
            #else
            NotificationCenter.default.addObserver(forName: .calculator_calculated, object: nil, queue: nil) { noti in
                if let markdownString = noti.object as? String {
                    history.insert(markdownString, at: 0)                    
                    if history.count > 20 {
                        history.removeLast()
                    }
                }
            }
            #endif
            
        }
        .background(Color.bg1)
        .toast(title:toastTitle, message: toastMessage, isShowing: $isToast, duration: 4)
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView()
    }
}
