//
//  Transcodeable.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/3/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public protocol Transcodeable {
    func encode() -> Data
    func decode(data: Data) -> Self
}

public extension Transcodeable {
    public func encode() -> Data {
        return Data(bytes: encodeBuffer())
    }
    public func decode(data: Data) -> Self {
        let buffer: [UInt8] = data.withUnsafeBytes {
            $0.pointee
        }
        return decode(buffer: buffer)
    }
}

fileprivate extension Transcodeable {
    func encodeBuffer() -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: MemoryLayout<Self>.size)
        buffer.withUnsafeMutableBufferPointer {
            UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: self, as: Self.self)
        }
        return buffer
    }
    func decode(buffer: [UInt8]) -> Self {
        return buffer.withUnsafeBufferPointer {
            UnsafeRawPointer($0.baseAddress!).load(as: Self.self)
        }
    }
}
