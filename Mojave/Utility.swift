//
//  Utility.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/28/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func append(_ rhs: [Key : Value]) {
        for (k, v) in rhs {
            updateValue(v, forKey: k)
        }
    }
}

extension Set {
    mutating func append(_ rhs: Set<Element>) {
        for e in rhs {
            update(with: e)
        }
    }
}

extension IndexSet {
    mutating func append(_ rhs: IndexSet) {
        for e in rhs {
            update(with: e)
        }
    }
}

func dispatch_async_safe_main_queue(_ block: @escaping () -> Void) {
    Thread.isMainThread ? block() : DispatchQueue.main.async(execute: block)
}

public enum Result<T> {
    case success(T)
    case error(Error)
}
