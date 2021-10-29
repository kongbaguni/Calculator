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
    static let btn1 = Color(nsColor: NSColor(named: "btn1")!)
    static let btn2 = Color(nsColor: NSColor(named: "btn2")!)
    static let btn3 = Color(nsColor: NSColor(named: "btn3")!)
    static let btnTextColor = Color(nsColor: NSColor(named: "btnTextColor")!)
    #else
    static let bg1 = Color(UIColor(named: "bg1")!)
    static let bg2 = Color(UIColor(named: "bg2")!)
    static let btn1 = Color(UIColor(named: "btn1")!)
    static let btn2 = Color(UIColor(named: "btn2")!)
    static let btn3 = Color(UIColor(named: "btn3")!)
    static let btnTextColor = Color(UIColor(named: "btnTextColor")!)
    #endif
}
