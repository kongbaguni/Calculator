//
//  HistoryListView.swift
//  Calculator
//
//  Created by Changyeol Seo on 2021/11/11.
//

import SwiftUI
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
    @State var isToast = false
    @State var toastTitle:Text? = nil
    @State var toastMessage = ""
    
    @State var isAlert = false
    @State var alertType = AlertType.deleteHistory
    @State var isShowEditMemo = false
    
    @State var query:String = ""
    @State var isLandscape = true
    @State var isKeyboardVisible = false
        
    @ObservedResults(HistoryModel.self) var historys
    
    
    var trimQuery : String {
        return query.trimmingCharacters(in: .whitespacesAndNewlines)
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
            NativeAdView()
            Spacer()
        }
    }
    
    var bannerViewLandscape : some View {
        HStack {
            Spacer()
            NativeAdView()
            Spacer()
        }
    }
    
    func makeHistoryView(model:HistoryModel.ThreadSafeModel)-> some View  {
        VStack(alignment:.leading) {
            HStack {
                Text("*")
                    .foregroundColor(.idxTextColor)
                Text(try! AttributedString(markdown: model.value))
                    .foregroundColor(.textColorNormal)
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
                    toastTitle = Text("copy to clipboard")
                    toastMessage = model.copyToPastboard()
                    isToast = true
                } label : {
                    Image(systemName: "doc.on.doc")
                }

                
                Button {
                    editId = model.id
                    isAlert = true
                    alertType = .deleteItem
                } label : {
                    Image(systemName: "trash")
                }
                
            }
        }.padding(.bottom, 5)

    }
    
    var historyListView : some View {
        LazyVStack(alignment:.leading) {
            ForEach(historys, id:\.self) { model in
                makeHistoryView(model: model.threadSafeModel)
            }
            
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
                        makeHistoryView(model: model)
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
        }
    }
    
    var landscapeLayout : some View {
        HStack {
            bannerViewLandscape
            ScrollView {
                historyListView
                deleteHistoryBtn
            }
        }
    }
    
    var portraitLayout : some View {
        ScrollView {
            historyListView
            bannerView
            deleteHistoryBtn
        }
    }
    
    var list:Results<HistoryModel> {
        Realm.shared.objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    var data:[Data] {
        var datas:[Data] = []
        var result:[String:[HistoryModel.ThreadSafeModel]] = [:]
        for model in list {
            let date = model.date.formatedString(format: DATE_FORMAT)!
            if result[date] == nil {
                result[date] = [model.threadSafeModel]
            } else {
                result[date]?.append(model.threadSafeModel)
            }
        }
        for item in result.sorted(by: { a, b in
            return a.key > b.key
        }) {
            datas.append(Data(date: item.key, list: item.value))
        }
        return datas
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
        .alert(isPresented: $isAlert, content: {
            switch alertType {
                case .lowPoint:
                    return Alert(
                        title: Text("low point warning"),
                        primaryButton: .default(Text("confirm"), action: {
                        }), secondaryButton: .cancel())

                case .showAd :
                    return Alert(
                        title: Text("show ad alert title"),
                        primaryButton: .default(Text("confirm"), action: {
                          
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
                            NotificationCenter.default.post(name: .calculator_db_updated, object: nil)
                        }
                    }
                    
                    deleteAll()
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
                                        NotificationCenter.default.post(name: .calculator_db_updated, object: nil)

                                    }
                                }
                            }
                        }
                        
                        deleteItem()
                        
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
        }
    }
}

