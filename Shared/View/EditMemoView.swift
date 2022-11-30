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
    let model:HistoryModel
    @State var text:String = ""
    var body: some View {
        VStack {
            Text("edit memo")
                .foregroundColor(.textColorWeak)
                .font(.system(size: 30, weight: .bold))
                .padding(20)
            Text(try! AttributedString(markdown: model.value))
                .foregroundColor(Color.textColorStrong)
                .font(.system(size: 20, weight: .bold))
                .padding(20)
            HStack {
                TextField("memo", text: $text)
                    .foregroundColor(.textColorNormal)
                    .padding(20)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    let realm = try! Realm()
                    realm.beginWrite()
                    model.memo = text
                    try! realm.commitWrite()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("confirm")
                }.padding(20)
            }
            Spacer()
        }
        .onAppear {
            text = model.memo
        }
    }
}

