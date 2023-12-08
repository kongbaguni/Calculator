//
//  AdView.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/11.
//

import SwiftUI
import ActivityIndicatorView
import GoogleMobileAds


extension Notification.Name {
    static let googleAdNativeAdClick = Notification.Name("googleAdNativeAdClick_observer")
    static let googleAdPlayVideo = Notification.Name("googleAdPlayVideo_observer")
}

struct NativeAdView : View {
    @State var loading = true
    @State var nativeAd:GADNativeAd? = nil
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                if let view = nativeAd?.view {
                    view
                }
                ActivityIndicatorView(isVisible: $loading, type: .default()).frame(width: 50, height: 50)
                    .frame(width:proxy.size.width, height: 350)
            }
        }.frame(height:350)
        .onAppear {
            loading = true
            AdLoader.shared.getNativeAd(getAd: {[self] ad in
                nativeAd = ad
                loading = false
            })
        }
    }
}

