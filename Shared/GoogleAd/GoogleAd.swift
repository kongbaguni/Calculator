//
//  GoogleADViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency


class GoogleAd : NSObject {
    
    var interstitial:GADRewardedAd? = nil
    
    private func loadAd(complete:@escaping(_ error:Error?)->Void) {
        let request = GADRequest()
        
        ATTrackingManager.requestTrackingAuthorization { status in
            print("google ad tracking status : \(status)")
            GADRewardedAd.load(withAdUnitID: AdIDs.rewardAd, request: request) { [weak self] ad, error in
                if let err = error {
                    print("google ad load error : \(err.localizedDescription)")
                }
                ad?.fullScreenContentDelegate = self
                self?.interstitial = ad
                complete(error)
            }
        }
    }
    
    var callback:(_ error:Error?)->Void = { _ in}
    
    var requsetAd = false
    
    func showAd(complete:@escaping(_ error:Error?)->Void) {
        if requsetAd {
            return
        }
        requsetAd = true
        callback = complete
        loadAd { [weak self] error in
            if let err = error {
                DispatchQueue.main.async {
                    complete(err)
                }
                return
            }
            self?.requsetAd = false 
            if let vc = UIApplication.shared.lastViewController {
                self?.interstitial?.present(fromRootViewController: vc, userDidEarnRewardHandler: {
                    
                })
            }
        }
    }
     
    
}

extension GoogleAd : GADFullScreenContentDelegate {
    //광고 실패
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("google ad \(#function)")
        print(error.localizedDescription)
        DispatchQueue.main.async {
            self.callback(error)
        }
    }
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고시작
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
    }
    //광고 종료
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("google ad \(#function)")
//        DispatchQueue.main.async {
//            PointModel.add(value: 10, desc: "show ad") { error in
//                self.callback(error)
//            }
//        }
    }
}
