//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationLink {
                
            } label: {
                Text("test")
            }

            CalculatorView()
        }
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
