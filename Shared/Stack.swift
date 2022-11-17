//
//  Stack.swift
//  Test
//
//  Created by Changyeol Seo on 2021/11/09.
//

import Foundation

struct Stack<T> {
    public var isEmpty: Bool {
        return self.list.isEmpty
    }
    
    public var top: T? {
        return self.list.last
    }
    
    mutating func push(_ item: T) {
        self.list.append(item)
    }
    
    mutating func pop() -> T? {
        return self.list.popLast()
    }
    
    public var list = [T]()
    
    public var count:Int {
        list.count
    }
    
}
