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
fileprivate let DATE_FORMAT = "yyyy.MM.dd hh:mm"

struct HistoryListView: View {
    struct Data:Hashable {
        let date:String
        let list:[String]
    }
    
    @State var data:[Data] = []
    let disposeBag = DisposeBag()
    
    var body: some View {
        VStack {
            if data.count == 0 {
                Text("empty history log...").multilineTextAlignment(.center)
            } else {
                List {
                    let list =
                    ForEach(data, id:\.self) { data in
                        Section(header: Text(data.date)) {
                            ForEach(data.list, id:\.self) { str in
                                let txt = HStack {
                                    Text("\((data.list.firstIndex(of: str) ?? 0) + 1)")
                                        .foregroundColor(Color.gray)
                                    Text(try! AttributedString(markdown: str))
                                        .foregroundColor(Color.btnTextColor)
                                }
                                #if MAC
                                txt
                                #else
                                txt.listRowSeparator(.hidden)
                                #endif

                            }
                        }
                        
                    }
                    #if MAC
                    list
                    #else
                    list.listStyle(GroupedListStyle())
                    #endif
                    
                    Button {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.deleteAll()
                        }
                    } label: {
                        Text("history_delete_button_title")
                    }
                }
            }
        }
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
