//
//  AdLoader.swift
//  ShootingGame
//
//  Created by Changyeol Seo on 2023/07/27.
//

import Foundation
import GoogleMobileAds
#if DEBUG
fileprivate let adId = "ca-app-pub-3940256099942544/3986624511"
#else
fileprivate let adId = "ca-app-pub-7714069006629518/1289022868"
#endif
class AdLoader : NSObject {
    static let shared = AdLoader()
    
    private let adLoader:GADAdLoader
        
    private var nativeAds:[GADNativeAd] = [] {
        didSet {
            if nativeAds.count > _adsCountMax {
                _adsCountMax = nativeAds.count
            }
        }
    }
    
    public var nativeAd:GADNativeAd? {
        if let ad = nativeAds.first {
            nativeAds.removeFirst()
            return ad
        }
        loadAd()
        return nil
    }
    
    private var _adsCountMax:Int = 0
    
    public var nativeAdsCount:Int {
        return _adsCountMax
    }
    
    private var callback:(_ ad:GADNativeAd)->Void = { _ in }
    public func getNativeAd(getAd:@escaping(_ ad:GADNativeAd)->Void) {
        if let ad = nativeAd {
            getAd(ad)
            return
        }
        loadAd()
        callback = getAd
    }
    
    override init() {
        let option = GADMultipleAdsAdLoaderOptions()
        option.numberOfAds = 4
        adLoader = GADAdLoader(adUnitID: adId,
                                    rootViewController: UIApplication.shared.lastViewController,
                                    adTypes: [.native], options: [option])
        super.init()
        adLoader.delegate = self
        loadAd()
    }
    
    private func loadAd() {
        adLoader.load(.init())
    }
        
}

extension AdLoader : GADNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("\(#function) \(#line) nativeAdsCount : \(nativeAds.count)")
        nativeAds.append(nativeAd)
        callback(nativeAd)
        callback = {_ in }
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("\(#function) \(#line) nativeAdsCount : \(nativeAds.count)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(#function) \(#line) \(error.localizedDescription)")
    }
    
}
