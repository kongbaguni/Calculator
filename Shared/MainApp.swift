//
//  MainApp.swift
//  Shared
//
//  Created by Changyeol Seo on 2021/10/06.
//

import SwiftUI
#if FULL
import FirebaseCore
#endif

#if FULL
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
    return true
  }
}
#endif

@main
struct MainApp: App {
    #if FULL
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
