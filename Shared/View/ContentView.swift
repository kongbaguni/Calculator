//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//
import SwiftUI
import GoogleMobileAds
import RealmSwift
struct ContentView: View {
    init() {
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "22c15f150946f2ec1887fe3673eff404","028bacd3552b31072f19a617f0c8aef3" ]
        // Sample device ID
        GADMobileAds.sharedInstance().start { status in
            print("-------------------------------")
            print("google ad status : \(status.adapterStatusesByClassName)")
        }
        let transparentAppearence = UITabBarAppearance()
        transparentAppearence.configureWithTransparentBackground()
        transparentAppearence.backgroundColor = UIColor(named: "bg3")
 
        UITabBar.appearance().standardAppearance = transparentAppearence
        UITabBar.appearance().scrollEdgeAppearance = transparentAppearence
    }
    @State var isShowHistory = false
    var body: some View {
        NavigationView {
            CalculatorView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("app_title")
                }
                .navigationTitle(Text("app_title"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                                        NavigationLink(destination:
                                                        HistoryListView()
                                            .navigationTitle(Text("history"))
                                            .navigationBarTitleDisplayMode(.large),
                                                       isActive: $isShowHistory,
                                                       label: { Text("history")})
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
