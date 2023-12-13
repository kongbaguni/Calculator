//
//  ContentView.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//
import SwiftUI
import GoogleMobileAds
import RealmSwift
import WidgetKit
import UserMessagingPlatform

struct ContentView: View {
    init() {
        GADMobileAds.sharedInstance().start { status in
            print("-------------------------------")
            print("google ad status : \(status.adapterStatusesByClassName)")
        }
        let transparentAppearence = UITabBarAppearance()
        transparentAppearence.configureWithTransparentBackground()
        transparentAppearence.backgroundColor = UIColor(named: "bg3")
 
        UITabBar.appearance().standardAppearance = transparentAppearence
        UITabBar.appearance().scrollEdgeAppearance = transparentAppearence
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { noti in
            WidgetCenter.shared.reloadAllTimelines()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            AppTrackingTransparancyHelper.requestTrackingAuthorization {
                
            }
        }
        GoogleAdPrompt.promptWithDelay {
            
        }
    }
    
    @State var isShowHistory = false
    
    var subview : some View {
        CalculatorView(isAppClip:false)
            .tabItem {
                Image(systemName: "square.and.pencil")
                Text("app_title")
            }
            .navigationTitle(Text("app_title"))
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var naviLink : some View {
        NavigationLink {
            HistoryListView()
                .navigationTitle(.init("history"))
        } label: {
            Image(systemName: "list.bullet.clipboard")
        }
    }
    
    var body: some View {
        NavigationView {
            if #available(iOS 16.0,*) {
                NavigationStack {
                    subview
                }
                .toolbar {
                    naviLink
                }

            } else {
                subview
                    .toolbar {
                        naviLink
                    }
            }
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
