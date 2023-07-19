//
//  UIApplication+Extensions.swift
//  Calculator
//
//  Created by 서창열 on 2022/05/12.
//

import Foundation
import SwiftUI

extension UIApplication {    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
extension UIApplication {
    var rootViewController:UIViewController? {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.last?.rootViewController
    }
    
    var lastViewController:UIViewController? {
        var vc = rootViewController
        if let ovc = vc {
            while ovc.presentedViewController != nil {
                vc = ovc.presentedViewController
            }
        }
        return vc
    }
}
