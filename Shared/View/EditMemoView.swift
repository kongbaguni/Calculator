//
//  EditMemoView.swift
//  Calculator
//
//  Created by 서창열 on 2022/11/30.
//

import SwiftUI
import RealmSwift

struct EditMemoView: View {
    @Environment(\.presentationMode) var presentationMode
//    let model:HistoryModel
    @AppStorage("adpoint") var adPoint = 0

    let googleAd = GoogleAd()
    let id:ObjectId
    var model:HistoryModel? {
        let realm = Realm.shared
        return realm.object(ofType: HistoryModel.self, forPrimaryKey: id)
    }
    
    @State var text:String = ""
    var body: some View {
        VStack {
            Text("edit memo")
                .foregroundColor(.textColorWeak)
                .font(.system(size: 30, weight: .bold))
                .padding(20)
            HStack {
                Text(try! AttributedString(markdown: model?.value ?? ""))
                    .foregroundColor(Color.textColorStrong)
                    .font(.system(size: 20, weight: .bold))
                    .padding(10)
                Spacer()
            }
            HStack {
                TextField("memo", text: $text)
                    .foregroundColor(.textColorNormal)
                    .padding(.leading,10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    func save() {
                        let realm = Realm.shared
                        realm.beginWrite()
                        model?.memo = text
                        try! realm.commitWrite()
                        presentationMode.wrappedValue.dismiss()
                        adPoint -= 1
                    }
                    if adPoint > 0 {
                        save()
                    } else {
                        googleAd.showAd { isSucess, time in
                            if isSucess {
                                adPoint += 5
                            }
                            save()
                        }
                    }
                } label: {
                    Text("confirm")
                }
                .padding(.trailing,10)
                .buttonStyle(BorderedButtonStyle())
            }
            Spacer()
        }
        .onAppear {
            text = model?.memo ?? ""
        }
    }
}

