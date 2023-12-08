//
//  GoogleAdId.swift
//  calculator (iOS)
//
//  Created by Changyeol Seo on 12/8/23.
//

import Foundation

struct AdIDs {
    #if DEBUG
    static let nativeAd = "ca-app-pub-3940256099942544/3986624511"
    static let rewardAd = "ca-app-pub-3940256099942544/1712485313"
    #else
    static let nativeAd = "ca-app-pub-7714069006629518/1289022868"
    static let rewardAd = "ca-app-pub-7714069006629518/6684078728"
    #endif
}
