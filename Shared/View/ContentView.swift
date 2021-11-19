//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        #if MAC
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
        }
        .frame(minWidth: 300, idealWidth: 300,
                maxWidth: CGFloat.greatestFiniteMagnitude,
                minHeight: 600, idealHeight: 600,
               maxHeight: CGFloat.greatestFiniteMagnitude, alignment: .center)
        #else
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
        }
        #endif
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
