//
//  KeyboardReadable.swift
//  Calculator
//
//  Created by 서창열 on 2022/12/02.
//
import Combine
#if !MAC
import UIKit
#endif


/// Publisher to read keyboard changes.
protocol KeyboardReadable {
#if !MAC
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
#endif
}

extension KeyboardReadable {
#if !MAC
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
#endif
}
