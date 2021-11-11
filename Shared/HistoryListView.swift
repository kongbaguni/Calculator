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

struct HistoryListView: View {
    @State var list:[String] = []
    let disposeBag = DisposeBag()
    
    var body: some View {
        VStack {
            if list.count == 0 {
                Text("empty history log...").multilineTextAlignment(.center)
            } else {
                List {
                    ForEach(list, id:\.self) { str in
                        
                        let txt = HStack {
                            Text("\((list.firstIndex(of: str) ?? 0) + 1)")
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
                        list = []
                        for item in dbList {
                            list.append(item.value)
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
