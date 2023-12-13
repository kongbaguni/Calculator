//
//  CalculatorView.swift
//  Test (iOS)
//
//  Created by Changyeol Seo on 2021/10/22.
//

import SwiftUI
#if FULL
import RealmSwift
#endif

struct Item {
    let color:Color
    let value:AnyHashable
    let imageName:String?
    let width:CGFloat
    var image:Image? {
        if let name = imageName {
            return .init(systemName:name)
        }
        return nil
    }
}
fileprivate let c1 = Color.btn1
fileprivate let c2 = Color.btn2
fileprivate let c3 = Color.btn3
fileprivate let c4 = Color.btn4


fileprivate let w:CGFloat = UIScreen.main.bounds.width * 0.1
fileprivate let w2:CGFloat = w * 2 + 10
fileprivate let list:[[Item]] = [
    [
        .init(color: c4, value: "(", imageName: nil, width:w),
        .init(color: c4, value: ")", imageName: nil, width:w),
        .init(color: c4, value: "clear", imageName: nil, width:w),
        .init(color: c4, value: "⌫", imageName: "delete.left", width: w)
    ],
    [
        .init(color: c1, value: "root", imageName: "x.squareroot", width: w),
        .init(color: c1, value: "+/-", imageName: "plus.forwardslash.minus", width:w),
        .init(color: c1, value: "%" , imageName: "percent", width:w),
        .init(color: c3, value: "÷" , imageName: "divide", width:w)
    ],
    
    [
        .init(color: c2, value: 7, imageName: nil, width:w),
        .init(color: c2, value: 8, imageName: nil, width:w),
        .init(color: c2, value: 9, imageName: nil, width:w),
        .init(color: c3, value: "✕", imageName: "multiply", width:w)
    ],
    [
        .init(color: c2, value: 4, imageName: nil, width:w),
        .init(color: c2, value: 5, imageName: nil, width:w),
        .init(color: c2, value: 6, imageName: nil, width:w),
        .init(color: c3, value: "-", imageName: "minus", width:w)
    ],
    [
        .init(color: c2, value: 1, imageName: nil, width:w),
        .init(color: c2, value: 2, imageName: nil, width:w),
        .init(color: c2, value: 3, imageName: nil, width:w),
        .init(color: c3, value: "+", imageName: "plus", width:w)
    ],
    [
        .init(color: c2, value: 0, imageName: nil, width:w2),
        .init(color: c2, value: ".", imageName: nil, width:w),
        .init(color: c3, value: "=", imageName: "equal",width:w)],
]

fileprivate var editNoteIdx:Int?

struct CalculatorView: View {
    enum AlertType {
        case deleteItem
        case onlyMessage
    }
    let isAppClip:Bool
    
    @State var count = 0
    @State var displayText:AttributedString = "0"
    @State var lastOp:String?
    @State var history:[String] = []
    #if FULL
    @State var historyModels:[HistoryModel.ThreadSafeModel] = []
    
    @State var isShowEditNote = false
    #endif
    @State var toastTitle:Text?
    @State var toastMessage = ""
    @State var isToast = false
    @State var isAlert = false
    @State var alertType:AlertType = .onlyMessage
    @State var alertMessage = ""
    @State var alertTitle = ""
    
    var 단항연산가능:Bool {
        Calculator.shared.items.last is Calculator.Number
    }
    
    var AC가능:Bool {
        Calculator.shared.items.count > 0
    }
    
    var DEL가능:Bool {
        return Calculator.shared.items.count > 0
    }
    
    var 괄호열기가능:Bool {
        let last = Calculator.shared.items.last
        let a = Calculator.shared.items.count == 0
        let b = last is Calculator.Operation
        let c = (last as? Calculator.Operation)?.type == .괄호열기
        let d = Calculator.shared.items.last is Calculator.Result
        let f = (last as? Calculator.Operation)?.type == .괄호닫기
        if f {
            return false
        }
        return a || b || c || d
    }
    
    var 괄호닫기가능:Bool {
        let items = Calculator.shared.items
        let last = items.last
    
        let counta = items.filter { item in
            return (item as? Calculator.Operation)?.type == .괄호열기
        }.count
        let countb = items.filter { item in
            return (item as? Calculator.Operation)?.type == .괄호닫기
        }.count
        
        let a = items.count > 0
        let b = last is Calculator.Number || (last as? Calculator.Operation)?.type == .괄호닫기
        return a && b && counta > countb
    }
    
    var 사칙연산자추가가능:Bool {
        let items = Calculator.shared.items
        let a = items.last is Calculator.Number
        let b = (items.last as? Calculator.Operation)?.type == .괄호닫기
        let c = (items.last as? Calculator.Operation)?.isFourArithmeticOperations == true
        return a || b || c
    }
    
    var 계산가능:Bool {
        let items = Calculator.shared.items
        let last = items.last
        let a = Calculator.shared.items.count > 1
        
        let counta = items.filter { item in
            return (item as? Calculator.Operation)?.type == .괄호열기
        }.count
        let countb = items.filter { item in
            return (item as? Calculator.Operation)?.type == .괄호닫기
        }.count
        
        let b = last is Calculator.Number || (last as? Calculator.Operation)?.type == .괄호닫기
        let c = counta == countb
        return a && b && c
    }
    
    var clearText:String {
        let last = Calculator.shared.items.last
        let a = last is Calculator.Number
        let b = (last as? Calculator.Operation)?.type == .괄호닫기
        let c = (last as? Calculator.Operation)?.type == .괄호열기
        if a || b || c {
            return "C"
        }
        return "AC"
    }
   

    var emptyHistoryView : some View {
        ScrollView {
            Text("empty history log...")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(Color.btnSelectedColor)
                .padding(50)
        }
    }
    
    var historylistViewlist : some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<history.count, id : \.self) { idx in
                    let texts = history[idx].components(separatedBy: " `=` ")
                    VStack {
                        HStack {
                            Text("*")
                                .foregroundColor(Color.idxTextColor)
                                .font(.system(size: 20,weight: .heavy))
                            
                            Text(try! AttributedString(markdown:texts.first!))
                                .foregroundColor(Color.btnTextColor)
                                .font(.system(size: 20,weight: .heavy))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(try! AttributedString(markdown:" `=` "))
                                .foregroundColor(Color.textColorWeak)
                                .font(.system(size: 20,weight: .heavy))
                            
                            Button {
                                if let txt = texts.last {
                                    let nt = txt.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "*", with: "")
                                    
                                    let number = Calculator.Number(strvalue: nt)
                                    Calculator.shared.items.removeAll()
                                    Calculator.shared.items.append(number)
                                }
                            } label: {
                                Text(try! AttributedString(markdown:texts.last!))
                                    .foregroundColor(Color.textColorStrong)
                                    .font(.system(size: 20,weight: .heavy))
                            }
                            Spacer()
                        }.fixedSize(horizontal: false, vertical: true)
#if FULL
                        HStack {
                            if historyModels[idx].memo.isEmpty == false {
                                Text(historyModels[idx].memo)
                                    .foregroundColor(Color.textColorWeak)
                            }
                            Spacer()
                            
                            Button {
                                print(idx)
                                editNoteIdx = idx
                                print(editNoteIdx!)
                                isShowEditNote = true
                            } label : {
                                Image(systemName: "square.and.pencil")
                            }
                            
                            Button {
                                toastTitle = Text("copy to clipboard")
                                toastMessage = historyModels[idx].copyToPastboard()
                                isToast = true
                            } label : {
                                Image(systemName: "doc.on.doc")
                            }
                            
                            Button {
                                editNoteIdx = idx
                                alertType = .deleteItem
                                isAlert = true
                            } label : {
                                Image(systemName: "trash")
                            }
                        }
#endif

                    }
                    .padding(.bottom, 5)
                    .overlay {
                        GeometryReader { geo in
                            Path { path in
                                path.move(to: .init(x: 0, y: geo.size.height))
                                path.addLine(to: .init(x:geo.size.width, y:geo.size.height))
                            }
                            .stroke(Color.teal, style: .init(lineWidth:1,dash:[4,4]))
                        }
                    }
                    .padding(10)
                }

            }
            
        }
        .background(Color.bg3)
        .listStyle(SidebarListStyle())
        .frame(minWidth: 300, idealWidth: 300, maxWidth: CGFloat.greatestFiniteMagnitude, minHeight: 100, idealHeight: 100, maxHeight: CGFloat.greatestFiniteMagnitude, alignment: .center)
    }
    
    var historylistView: some View {
        Group {
            if history.count == 0 {
                emptyHistoryView
            } else {
                historylistViewlist
            }
            if isAppClip {
                Button {
                    let url = URL(string:"https://apps.apple.com/us/app/kong-calculator/id1594969449")!
                    UIApplication.shared.open(url)
                } label: {
                    Text("View in App Store")
                }

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
//                    .background(KeyEventHandling())
//                TODO : iOS 에서 키 이벤트 핸들링 방법 찾아볼것
            }
        }
        .frame(height: 100)
        .background(Color.bg2)
        .onTapGesture {
            Calculator.shared.delLastNumber()
        }
        .onLongPressGesture {
            let txt = Calculator.shared.normalStringForClipboardShare
            UIPasteboard.general.string = txt
            isToast = true
            toastTitle = Text("copy to clipboard")
            toastMessage = txt            
            print("longPress")
        }

    }
    
    func makeButtons(height:CGFloat)-> some View {
        HStack {
            #if FULL
            NativeAdView()
            #endif
            VStack {
                ForEach(0..<list.count, id:\.self) { i in
                    HStack {
                        ForEach(0..<list[i].count, id:\.self) { a in
                            let item = list[i][a]
                            let str = item.value as? String ?? "\(item.value as! Int)"
                            let width:CGFloat = item.width
                            let color = item.color
                            let isEnable = str == "(" ? 괄호열기가능
                            : str == ")" ? 괄호닫기가능
                            : str == "=" ? 계산가능
                            : str == "clear" ? AC가능
                            : str == "⌫" ? DEL가능
                            : ["÷","✕","-","+"].firstIndex(of: str) != nil ? 사칙연산자추가가능
                            : ["root","+/-","%"].firstIndex(of: str) != nil ? 단항연산가능
                            : true
                            let nh = (height / CGFloat(list.count > 0 ? list.count : 1)) - 10
                            let rowHeight = nh < 0 ? 0 : nh
                            
                            
                            Button {
                                if isEnable {
                                    if str == "clear" {
                                        Calculator.shared.keyInput(key: clearText)
                                    } else {
                                        #if FULL
                                        Calculator.shared.keyInput(key: str)
                                        #else
                                        Calculator.shared.keyInput(key: str)
                                        #endif
                                    }
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(str == lastOp && ["÷","✕","-","+"].firstIndex(of: str) != nil ? Color.btnSelectedColor : color)
                                    if let img = item.image {
                                        img
                                            .foregroundColor(Color.btnTextColor)
                                            .symbolRenderingMode(.hierarchical)
                                        
                                    }
                                    else if str == "clear" {
                                        Text(try! AttributedString(markdown: "`\(clearText)`"))
                                            .foregroundColor(Color.btnTextColor)
                                            .padding(0.5)
                                    } else {
                                        Text(try! AttributedString(markdown: "`\(str)`"))
                                            .foregroundColor(Color.btnTextColor)
                                            .padding(0.5)
                                    }
                                }
                                .frame(width: width, height:rowHeight , alignment: .center)
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
        }.frame(height:height)
    }
    
    func loadHistoryData() {
#if FULL
        var results:[String] = []
        var models:[HistoryModel.ThreadSafeModel] = []
        
        for item in Realm.shared.objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: false).prefix(20) {
            results.append(item.value)
            models.append(item.threadSafeModel)
            print(item.threadSafeModel.memo)
        }
        history.removeAll()
        historyModels.removeAll()
        history = results
        historyModels = models
        print(results)
#endif
    }
    
    var body: some View {
        GeometryReader { geomentry in
            if geomentry.size.width < geomentry.size.height {
                // 세로
                VStack {
                    numberDisplayView
                        .padding(.horizontal, 5)
                    historylistView
                        .padding(.horizontal, 5)
                    Spacer().frame(width: 300, height: 20, alignment: .center)
                    makeButtons(height: 360)
                        .padding(5)
                    Spacer().frame(width: 300, height: 20, alignment: .center)
                }
            } else {
                //가로
                HStack {
                    VStack {
                        numberDisplayView
                            .padding(.horizontal, 5)
                        historylistView
                            .padding(.horizontal, 5)
                    }
                    .padding(.vertical,20)
                    VStack {
                        Spacer()
                        makeButtons(height: geomentry.size.height - 20)
                            .padding(5)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
#if FULL
            let config = Realm.Configuration(
                schemaVersion: 2)
            // Use this configuration when opening realms
            Realm.Configuration.defaultConfiguration = config
            loadHistoryData()
#endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .calculator_lastNumber), perform: { noti in
            displayText = Calculator.shared.displayAttributedString
            lastOp = nil
        })
        .onReceive(NotificationCenter.default.publisher(for: .calculator_lastOperator), perform: { noti in
            displayText = Calculator.shared.displayAttributedString
            if let op = noti.object as? Calculator.Operation {
                lastOp = op.type.rawValue
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .calculator_calculated), perform: { noti in
            if let markdownString = noti.object as? String {
                history.insert(markdownString, at: 0)
                if history.count > 20 {
                    history.removeLast()
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .calculator_db_updated), perform: { noti in
            loadHistoryData()
        })
#if FULL
        .sheet(isPresented: $isShowEditNote, content: {
            let model = historyModels[editNoteIdx!]
            EditMemoView(id: model.id)
        })
#endif
        .alert(isPresented: $isAlert, content: {
            switch alertType {
            case .deleteItem:
                    return Alert(title: Text("history_delete_alert_title"),
                                 message: Text("history_delete_alert_message"),
                                 primaryButton: .default(Text("history_delete_alert_confirm"),
                                                         action: {
#if FULL
                        func deleteItem() {
                            if let i = editNoteIdx {
                                editNoteIdx = nil
                                let id = historyModels[i].id
                                let realm = Realm.shared
                                if let target = realm.object(ofType: HistoryModel.self, forPrimaryKey: id) {
                                    try! realm.write {
                                        realm.delete(target)
                                        NotificationCenter.default.post(name: .calculator_db_updated, object: nil)
                                    }
                                }
                            }
                        }
                        deleteItem()
#endif
                    }),
                                 secondaryButton: .cancel())
            case .onlyMessage:
                    return Alert(title: Text(alertTitle),
                                 message: Text(alertMessage))
                    
            }
        })
        .background(Color.bg1)
        .toast(title:toastTitle, message: toastMessage, isShowing: $isToast, duration: 4)
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(isAppClip:false)
    }
}
