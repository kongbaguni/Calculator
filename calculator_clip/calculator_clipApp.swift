//
//  calculator_clipApp.swift
//  calculator_clip
//
//  Created by Changyeol Seo on 2021/10/21.
//

import SwiftUI

@main
struct calculator_clipApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView(isAppClip:true)
        }
    }
}
