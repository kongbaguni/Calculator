//
//  HistoryListView.swift
//  Calculator
//
//  Created by Changyeol Seo on 2021/11/11.
//

import SwiftUI
import RxSwift
import RxRealm
import RealmSwift
fileprivate let DATE_FORMAT = "yyyy.MM.dd"
fileprivate var editId:ObjectId? = nil

struct HistoryListView: View , KeyboardReadable {
    struct Data:Hashable {
        static func == (lhs: HistoryListView.Data, rhs: HistoryListView.Data) -> Bool {
            lhs.date == rhs.date && lhs.list == rhs.list
        }
        
        let date:String
        let list:[HistoryModel.ThreadSafeModel]
    }
    enum AlertType {
        case deleteHistory
        case adWatchTime
        case deleteItem
        case showAd
        case lowPoint
    }
    let googleAd = GoogleAd()
    @AppStorage("adpoint") var adPoint = 0
    @State var isToast = false
    @State var toastTitle:Text? = nil
    @State var toastMessage = ""
    
    @State var isAlert = false
    @State var alertType = AlertType.deleteHistory
    @State var isShowEditMemo = false
    
    @State var data:[Data] = []
    @State var query:String = ""
    @State var isLandscape = true
    @State var isKeyboardVisible = false
//    init() {
//        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [self] note in
//            isLandscape.toggle()
//        }
//    }
        
    var trimQuery : String {
        return query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    let disposeBag = DisposeBag()
    var watchAdBtn : some View {
        Button {
            isAlert = true
            alertType = .showAd
        } label : {
            HStack {
                Image(systemName: "video.circle")
                    .imageScale(.large)
                    .foregroundColor(Color.btnTextColor)
                    .padding(.trailing,5)
                
                Text("watch AD")
                    .font(.headline)
                    .foregroundColor(Color.btnTextColor)
                
                Text("Ad Point : \(adPoint)")
            }
            .padding(5)
            
        }
    }
    
    var deleteHistoryBtn : some View {
        Button {
            alertType = .deleteHistory
            isAlert = true
        } label: {
            HStack {
                Image(systemName:"trash.circle")
                    .imageScale(.large)
                    .foregroundColor(Color.btnTextColor)
                    .padding(.trailing,5)
                Text("history_delete_button_title")
                    .font(.headline)
                    .foregroundColor(Color.btnTextColor)
            }
            .padding(5)

        }
    }
    
    var bannerView : some View {
        HStack {
            Spacer()
            NativeAdView(size: .init(width: UIScreen.main.bounds.width - 20, height: 400))
            Spacer()
        }
    }
    
    var historyListView : some View {
        LazyVStack {
            ForEach(data, id:\.self) { data in
                Section(header: HStack {
                    Text(data.date)
                        .foregroundColor(.textColorWeak)
                    Spacer()
                }
                    .padding(.leading, 5)
                    .padding(.top, 20)
                ) {
                    ForEach(data.list, id:\.self) { model in
                        VStack {
                            HStack {
                                Text("*")
                                    .foregroundColor(.idxTextColor)
                                Text(try! AttributedString(markdown: model.value))
                                    .foregroundColor(.textColorNormal)
                                Spacer()
                            }
                            HStack {
                                Text("memo :")
                                    .foregroundColor(.textColorWeak)
                                
                                model.isMemoEmpty
                                ? Text("none").foregroundColor(.textColorWeak)
                                : Text(model.memo).foregroundColor(.textColorNormal)
                                
                                Button {
                                    if adPoint < 1 {
                                        isAlert = true
                                        alertType = .lowPoint
                                    } else {
                                        editId = model.id
                                        isShowEditMemo = true
                                    }
                                } label : {
                                    Image(systemName: "square.and.pencil")
                                }
                                
                                Button {                                    
                                    toastTitle = Text("copy to clipboard")
                                    toastMessage = model.copyToPastboard()
                                    isToast = true
                                } label : {
                                    Image(systemName: "doc.on.doc")
                                }

                                
                                Button {
                                    editId = model.id
                                    isAlert = true
                                    if adPoint < 1 {
                                        alertType = .lowPoint
                                    } else {
                                        alertType = .deleteItem
                                    }
                                } label : {
                                    Image(systemName: "trash")
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(5)
                        .background(
                            model.memo.components(separatedBy: trimQuery).count > 1 ? Color.bg3 : Color.bg2)
                        .padding(.leading,5)
                        .padding(.trailing,5)
                        .cornerRadius(5)
                        
                    }
                }
            }
        }
    }
    var emptyView : some View {
        VStack {
            bannerView
            Text("empty history log...")
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(Color.btnSelectedColor)
                .padding(50)
            watchAdBtn
        }
    }
    
    var landscapeLayout : some View {
        HStack {
            bannerView
            ScrollView {
                historyListView
                deleteHistoryBtn
                watchAdBtn
            }
        }
    }
    
    var portraitLayout : some View {
        ScrollView {
            historyListView
            bannerView
            deleteHistoryBtn
            watchAdBtn
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            VStack {
                if data.count == 0 {
                    emptyView
                }
                else if geomentry.size.width < geomentry.size.height || isKeyboardVisible {
                    portraitLayout
                } else {
                    landscapeLayout
                }
            }
        }
        .toast(title:toastTitle, message: toastMessage, isShowing: $isToast, duration: 4)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
//        #else
//        .searchable(text: $query, placement: .toolbar)
        .alert(isPresented: $isAlert, content: {
            switch alertType {
                case .lowPoint:
                    return Alert(
                        title: Text("low point warning"),
                        primaryButton: .default(Text("confirm"), action: {
                            googleAd.showAd { isSucess, time in
                                if isSucess {
                                    adPoint += 5
                                }
                                else {
                                    alertType = .adWatchTime
                                    isAlert = !isSucess
                                }
                            }
                        }), secondaryButton: .cancel())

                case .showAd :
                    return Alert(
                        title: Text("show ad alert title"),
                        primaryButton: .default(Text("confirm"), action: {
                            googleAd.showAd { isSucess, time in
                                if isSucess {
                                    adPoint += 5
                                }
                                else {
                                    alertType = .adWatchTime
                                    isAlert = !isSucess
                                }
                            }
                        }), secondaryButton: .cancel())
            case .deleteHistory:
                return Alert(title: Text("history_delete_alert_title"),
                             message: Text("history_all_delete_alert_message"),
                             primaryButton: .default(Text("history_delete_alert_confirm"),
                                                     action: {
                    func deleteAll() {
                        let realm = Realm.shared
                        try! realm.write {
                            realm.deleteAll()
                        }
                        adPoint -= 1
                    }
                    
                    if adPoint > 0 {
                        deleteAll()
                    } else {
                        googleAd.showAd { isSucess, time in
                            if isSucess {
                                adPoint += 5
                            }
                            deleteAll()
                        }
                    }
                }),
                             secondaryButton: .cancel())
            case .adWatchTime:
                return Alert(title: Text("ad watch time error title"),
                             message: Text("ad watch time error message"),
                             dismissButton: .cancel(Text("ad watch time error confirm")))
            case .deleteItem:
                    return Alert(title: Text("history_delete_alert_title"),
                                 message: Text("history_delete_alert_message"),
                                 primaryButton: .default(Text("history_delete_alert_confirm"),
                                                         action: {
                        func deleteItem() {
                            if let id = editId {
                                editId = nil
                                let realm = Realm.shared
                                if let target = realm.object(ofType: HistoryModel.self, forPrimaryKey: id) {
                                    try! realm.write {
                                        realm.delete(target)
                                    }
                                }
                                adPoint -= 1
                            }
                        }
                        
                        if adPoint > 0 {
                            deleteItem()
                        } else {
                            googleAd.showAd { isSucess, _ in
                                if isSucess {
                                    adPoint += 5
                                }
                                deleteItem()
                            }
                        }
                        
                    }),
                                 secondaryButton: .cancel())

            }
        })
        .sheet(isPresented: $isShowEditMemo, content: {
            if let id = editId {
                EditMemoView(id:id)
            }
        })
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            print("Is keyboard visible? ", newIsKeyboardVisible)
            isKeyboardVisible = newIsKeyboardVisible
        }
        .onAppear {
            isLandscape = UIDevice.current.orientation.isLandscape
            Observable.collection(from: Realm.shared.objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: true))
                .subscribe { event in
                    switch event {
                    case .next(let dbList):
                        data.removeAll()
                        var result:[String:[HistoryModel.ThreadSafeModel]] = [:]
                        
                        for item in dbList {
                            let date = item.date.formatedString(format: DATE_FORMAT)!
                            if result[date] == nil {
                                result[date] = [item.threadSafeModel]
                            } else {
                                result[date]?.append(item.threadSafeModel)
                            }
                        }
                        for item in result {
                            data.append(Data(date: item.key, list: item.value))
                        }
                        data = data.sorted { a, b in
                            if let datea = a.date.dateValue(format: DATE_FORMAT),
                               let dateb = b.date.dateValue(format: DATE_FORMAT) {
                                return datea.timeIntervalSince1970 < dateb.timeIntervalSince1970
                            }
                            return false
                        }
                        
                    case .error(let error):
                        print(error.localizedDescription)
                        break
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
            
        }
    }
}

