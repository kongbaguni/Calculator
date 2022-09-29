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

struct HistoryListView: View {
    struct Data:Hashable {
        let date:String
        let list:[String]
    }
    enum AlertType {
        case deleteHistory
        case adWatchTime
    }
    #if !MAC
    let googleAd = GoogleAd()
    #endif
    
    
    @State var isAlert = false
    @State var alertType = AlertType.deleteHistory

    @State var data:[Data] = []
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
            Spacer()
#endif
        }
    }
    
    var historyListView : some View {
        LazyVStack {
            ForEach(data, id:\.self) { data in
                Section(header: Text(data.date)) {
                    ForEach(data.list, id:\.self) { str in
                        HStack {
                            Text("\((data.list.firstIndex(of: str) ?? 0) + 1)")
                                .foregroundColor(Color.gray)
                            Text(try! AttributedString(markdown: str))
                                .foregroundColor(Color.btnTextColor)
                            Spacer()
                        }
                        .padding(5)
                        .background(Color.bg2)
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
                    if geomentry.size.width < geomentry.size.height {
                        ScrollView {
                            bannerView
                            historyListView
                            deleteHistoryBtn
                            watchAdBtn
                        }
                    } else {
                        HStack {
                            bannerView
                            ScrollView {
                                historyListView
                                deleteHistoryBtn
                                watchAdBtn
                             }
                        }
                    }

                }
            }

        }
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
            }
        })
        .onAppear {
            Observable.collection(from: try! Realm().objects(HistoryModel.self).sorted(byKeyPath: "date", ascending: true))
                .subscribe { event in
                    switch event {
                    case .next(let dbList):
                        self.data = []
                        var result:[String:[String]] = [:]
                        
                        for item in dbList {
                            let date = item.date.formatedString(format: DATE_FORMAT)!
                            if result[date] == nil {
                                result[date] = [item.value]
                            } else {
                                result[date]?.append(item.value)
                            }
                        }
                        print(result)
                        data = []
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

struct HistoryListView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListView()
    }
}
