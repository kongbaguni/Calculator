//
//  Toast.swift
//  PixelArtMaker (iOS)
//
//  Created by Changyul Seo on 2022/04/03.
//
// https://swiftuirecipes.com/blog/swiftui-toast
import SwiftUI

struct Toast: ViewModifier {
    // these correspond to Android values f
    // or DURATION_SHORT and DURATION_LONG
    static let short: TimeInterval = 2
    static let long: TimeInterval = 3.5
    
    let title:Text?
    let message: String
    @Binding var isShowing: Bool
    let config: Config
    
    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }
    
    private var toastView: some View {
        VStack {
            Spacer()
            if isShowing {
                VStack {
                    if let t = title {
                        t
                            .multilineTextAlignment(.center)
                            .foregroundColor(config.titleColor)
                            .font(config.font)
                    }
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(config.textColor)
                        .font(config.font)
                }
                .padding(8)
                .background(config.backgroundColor)
                .cornerRadius(8)
                .onTapGesture {
                    isShowing = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                        isShowing = false
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(config.animation, value: isShowing)
        .transition(config.transition)
    }
    
    struct Config {
        let titleColor : Color
        let textColor: Color
        let font: Font
        let backgroundColor: Color
        let duration: TimeInterval
        let transition: AnyTransition
        let animation: Animation
        
        init(
            titleColor: Color = .yellow,
            textColor: Color = .white,
             font: Font = .system(size: 14),
             backgroundColor: Color = .black.opacity(0.588),
             duration: TimeInterval = Toast.short,
             transition: AnyTransition = .opacity,
             animation: Animation = .linear(duration: 0.3)) {
                 self.titleColor = titleColor
                 self.textColor = textColor
                 self.font = font
                 self.backgroundColor = backgroundColor
                 self.duration = duration
                 self.transition = transition
                 self.animation = animation
        }
    }
}

extension View {
    func toast(
            title:Text? = nil,
               message: String,
               isShowing: Binding<Bool>,
               config: Toast.Config) -> some View {
                   self.modifier(Toast(title: title,
                                       message: message,
                                       isShowing: isShowing,
                                       config: config))
    }
    
    func toast(
        title:Text? = nil,
        message: String,
        isShowing: Binding<Bool>,
        duration: TimeInterval) -> some View {
        self.modifier(Toast(title:title,
                            message: message,
                            isShowing: isShowing,
                            config: .init(duration: duration)))
    }
}
