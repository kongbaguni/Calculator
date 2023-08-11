//
//  AdView.swift
//  GaweeBaweeBoh
//
//  Created by Changyeol Seo on 2023/07/11.
//

import SwiftUI
import GoogleMobileAds
import ActivityIndicatorView

extension Notification.Name {
    static let googleAdNativeAdClick = Notification.Name("googleAdNativeAdClick_observer")
    static let googleAdPlayVideo = Notification.Name("googleAdPlayVideo_observer")
}

struct NativeAdView : View {
    let size:CGSize
    @State var loading = true
    @State var nativeAd:GADNativeAd? = nil
    
    var body: some View {
        ZStack {
            if let view = nativeAd?.makeView(size: size) {
                view
            }
            VStack(alignment: .center) {
                ActivityIndicatorView(isVisible: $loading, type: .default()).frame(width: 50, height: 50)
                    .padding(50)
            }.frame(height:350)
        }.onAppear {
            loading = true
            AdLoader.shared.getNativeAd(getAd: {[self] ad in
                nativeAd = ad
                loading = false
            })
        }

    }
}

