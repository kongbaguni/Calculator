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
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { noti in
            WidgetCenter.shared.reloadAllTimelines()
        }
        GoogleAd().requestTrackingAuthorization { [self] in
            ump()
        }
    }
    
    func ump() {
        func loadForm() {
          // Loads a consent form. Must be called on the main thread.
            UMPConsentForm.load { form, loadError in
                if loadError != nil {
                  // Handle the error
                } else {
                    // Present the form. You can also hold on to the reference to present
                    // later.
                    if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.required {
                        form?.present(
                            from: UIApplication.shared.lastViewController!,
                            completionHandler: { dismissError in
                                if UMPConsentInformation.sharedInstance.consentStatus == UMPConsentStatus.obtained {
                                    // App can start requesting ads.
                                }
                                // Handle dismissal by reloading form.
                                loadForm();
                            })
                    } else {
                        // Keep the form available for changes to user consent.
                    }
                    
                }

            }
        }
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. Here false means users are not under age.
        parameters.tagForUnderAgeOfConsent = false
        #if DEBUG
        let debugSettings = UMPDebugSettings()
//        debugSettings.testDeviceIdentifiers = ["78ce88aff302a5f4dfa5226a766c0b5a"]
        debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        #endif
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters,
            completionHandler: { error in
                if error != nil {
                    // Handle the error.
                    print(error!.localizedDescription)
                } else {
                    let formStatus = UMPConsentInformation.sharedInstance.formStatus
                    if formStatus == UMPFormStatus.available {
                      loadForm()
                    }

                }
            })
    }

    @State var isShowHistory = false
    var body: some View {
        NavigationView {
            CalculatorView(isAppClip:false)
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
