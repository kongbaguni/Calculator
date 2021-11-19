//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalculatorView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("app_title")
                }
            HistoryListView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("history")
                }
        }.frame(minWidth: 300, idealWidth: 300,
                maxWidth: CGFloat.greatestFiniteMagnitude,
                minHeight: 700, idealHeight: 700, maxHeight: CGFloat.greatestFiniteMagnitude, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, .init(identifier : "en"))
        
        ContentView()
            .environment(\.locale, .init(identifier : "ko"))
    }
}
