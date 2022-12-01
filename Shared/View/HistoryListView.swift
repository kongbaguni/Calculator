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
fileprivate let DATE_FORMAT = "yyyy.MM.dd HH:mm"
fileprivate var editId:ObjectId? = nil

struct HistoryListView: View {
    struct Data:Hashable {
        static func == (lhs: HistoryListView.Data, rhs: HistoryListView.Data) -> Bool {
            return lhs.date == rhs.date
        }
        
        let date:String
        let list:[HistoryModel.ThreadSafeModel]
    }
    enum AlertType {
        case deleteHistory
        case adWatchTime
        case deleteItem
    }
    #if !MAC
    let googleAd = GoogleAd()
    #endif
    
    
    @State var isAlert = false
    @State var alertType = AlertType.deleteHistory
    @State var isShowEditMemo = false
    
    @State var data:[Data] = []
    @State var query:String = ""
    
    var trimQuery : String {
        return query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    let disposeBag = DisposeBag()
    var watchAdBtn : some View {
#if !MAC
        Button {
            googleAd.showAd { isSucess, time in
                if isSucess == false {
                    alertType = .adWatchTime
                    isAlert = !isSucess
                }
            }
        } label : {
            HStack {
                Image(systemName: "video.circle")
                    .imageScale(.large)
                    .foregroundColor(Color.btnTextColor)
                    .padding(.trailing,5)
                
                Text("watch AD")
                    .font(.headline)
                    .foregroundColor(Color.btnTextColor)
            }
            .padding(5)
            
        }
#else
        EmptyView()
#endif
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
#if !MAC
            
            Spacer()
            BannerAdView(sizeType: .GADAdSizeMediumRectangle, padding: .zero)
                .padding(10)
            Spacer()
#endif
        }
    }
    
    var historyListView : some View {
        LazyVStack {
            ForEach(data, id:\.self) { data in
                Section(header: Text(data.date)) {
                    ForEach(data.list, id:\.self) { model in
                        VStack {
                            HStack {
                                Text("\((data.list.firstIndex(of: model) ?? 0) + 1)")
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
                                    editId = model.id
                                    isShowEditMemo = true
                                } label : {
                                    Image(systemName: "square.and.pencil")
                                }
                                
                                Button {
                                    editId = model.id
                                    isAlert = true
                                    alertType = .deleteItem
                                } label : {
                                    Image(systemName: "trash")
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(5)                        
                        .background(
                            model.memo.components(separatedBy: trimQuery).count > 1 ? Color.bg3 : Color.bg2)
                        .cornerRadius(5)
                        .padding(5)
                        
                    }
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geomentry in
            VStack {
                if data.count == 0 {
                    bannerView
                    Text("empty history log...")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundColor(Color.btnSelectedColor)
                        .padding(50)
                    watchAdBtn
                } else {
                    switch UIDevice.current.orientation {
                        case .landscapeLeft, .landscapeRight:
                            HStack {
                                bannerView
                                ScrollView {
                                    historyListView
                                    deleteHistoryBtn
                                    watchAdBtn
                                }
                            }
                        default:
                            ScrollView {
                                historyListView
                                bannerView
                                deleteHistoryBtn
                                watchAdBtn
                            }
                    }
                }
            }
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .alert(isPresented: $isAlert, content: {
            switch alertType {
            case .deleteHistory:
                return Alert(title: Text("history_delete_alert_title"),
                             message: Text("history_delete_alert_message"),
                             primaryButton: .default(Text("history_delete_alert_confirm"),
                                                     action: {
                    let realm = try! Realm()
                    try! realm.write {
                        realm.deleteAll()
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
                        if let id = editId {
                            editId = nil
                            let realm = try! Realm()
                            if let target = realm.object(ofType: HistoryModel.self, forPrimaryKey: id) {
                                try! realm.write {
                                    realm.delete(target)
                                }
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
        .onAppear {
            Observable.collection(from: try! Realm().objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: true))
                .subscribe { event in
                    switch event {
                    case .next(let dbList):
                        self.data.removeAll()
                        var result:[String:[HistoryModel.ThreadSafeModel]] = [:]
                        
                        for item in dbList {
                            let date = item.date.formatedString(format: DATE_FORMAT)!
                            if result[date] == nil {
                                result[date] = [item.threadSafeModel]
                            } else {
                                result[date]?.append(item.threadSafeModel)
                            }
                        }
                        print(result)
                        data.removeAll()
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

