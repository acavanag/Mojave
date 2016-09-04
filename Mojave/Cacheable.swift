//
//  Cacheable.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/3/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public protocol Cacheable {
    func encode(with: Coder) -> Data
    init?(with: Coder)
}

public struct Coder: Transcodeable {
    private var values = [String : [UInt8]]()
    
    mutating func encode<T>(_ value: T, for key: String) {
        values[key] = toByteArray(value)
    }
    func decode<T>(for key: String) -> T? {
        guard let value = values[key] else { return nil }
        return fromByteArray(value, T.self)
    }
}

extension Coder {
    fileprivate func toByteArray<T>(_ value: T) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        data.withUnsafeMutableBufferPointer {
            UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: value, as: T.self)
        }
        return data
    }
    fileprivate func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBufferPointer {
            UnsafeRawPointer($0.baseAddress!).load(as: T.self)
        }
    }
}






