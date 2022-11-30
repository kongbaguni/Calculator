//
//  Color.swift
//  Test
//
//  Created by Changyeol Seo on 2021/10/27.
//

import Foundation
import SwiftUI

extension Color {
    #if MAC
    static let bg1 = Color(nsColor: NSColor(named: "bg1")!)
    static let bg2 = Color(nsColor: NSColor(named: "bg2")!)
    static let bg3 = Color(nsColor: NSColor(named: "bg3")!)
    static let btn1 = Color(nsColor: NSColor(named: "btn1")!)
    static let btn2 = Color(nsColor: NSColor(named: "btn2")!)
    static let btn3 = Color(nsColor: NSColor(named: "btn3")!)
    static let btn4 = Color(nsColor: NSColor(named: "btn4")!)
    static let btnTextColor = Color(nsColor: NSColor(named: "btnTextColor")!)
    static let btnSelectedColor = Color(nsColor: NSColor(named: "btnSelectedColor")!)
    static let idxTextColor = Color(nsColor: NSColor(named: "idxTextColor")!)
    static let textColorNormal = Color(nsColor: NSColor(named: "textColorNormal")!)
    static let textColorStrong = Color(nsColor: NSColor(named: "textColorStrong")!)
    static let textColorWeak = Color(nsColor: NSColor(named: "textColorWeak")!)
    #else
    static let bg1 = Color(UIColor(named: "bg1")!)
    static let bg2 = Color(UIColor(named: "bg2")!)
    static let bg3 = Color(UIColor(named: "bg3")!)
    static let btn1 = Color(UIColor(named: "btn1")!)
    static let btn2 = Color(UIColor(named: "btn2")!)
    static let btn3 = Color(UIColor(named: "btn3")!)
    static let btn4 = Color(UIColor(named: "btn4")!)
    static let btnTextColor = Color(UIColor(named: "btnTextColor")!)
    static let btnSelectedColor = Color(UIColor(named: "btnSelectedColor")!)
    static let idxTextColor = Color(UIColor(named: "idxTextColor")!)
    static let textColorNormal = Color(UIColor(named: "textColorNormal")!)
    static let textColorStrong = Color(UIColor(named: "textColorStrong")!)
    static let textColorWeak = Color(UIColor(named: "textColorWeak")!)
    #endif
}
