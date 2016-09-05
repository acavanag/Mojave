//
//  Cacheable.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/3/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public typealias Values = [String : [UInt8]]

public protocol Cacheable {
    func encode(with coder: Coder)
    init?(with coder: Coder)
}

public final class Coder {
    fileprivate var values: Values
    
    init(values: Values = [:]) {
        self.values = values
    }
    
    public func encode<T: ByteRepresentable>(_ value: T, for key: String) {
        values[key] = Coder.toByteArray(value)
    }
    
    public func decode<T: ByteRepresentable>(for key: String) -> T? {
        guard let value = values[key] else { return nil }
        return Coder.fromByteArray(value, T.self)
    }
}

internal extension Coder {
    static func toByteArray<T>(_ value: T) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
        data.withUnsafeMutableBufferPointer {
            UnsafeMutableRawPointer($0.baseAddress!).storeBytes(of: value, as: T.self)
        }
        return data
    }
    
    static func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBufferPointer {
            UnsafeRawPointer($0.baseAddress!).load(as: T.self)
        }
    }
}

internal extension Coder {
    func encodeToData() -> Data {
        return Data(bytes: encodeValues())
    }
    static func decode(from data: Data) -> Values {
        var bufferCopy = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &bufferCopy, count: data.count)
        return decodeValues(bufferCopy)
    }
}

private extension Coder {
    func encodeValues() -> [UInt8] {
        var valueBuffer = [UInt8]()
        for (key, buffer) in values {
            let keyBuffer = key.toByteArray()
            valueBuffer.append(UInt8(keyBuffer.count))
            valueBuffer.append(UInt8(buffer.count))
            valueBuffer.append(contentsOf: keyBuffer)
            valueBuffer.append(contentsOf: buffer)
        }
        return valueBuffer
    }
    
    static func decodeValues(_ buffer: [UInt8]) -> Values {
        var contents = Values()
        
        var offset = 2
        var keyIndex = 0
        var bufferIndex = 1
        
        while offset < buffer.count {
            let currentKeySize = Int(buffer[keyIndex])
            let currentBufferSize = Int(buffer[bufferIndex])
            
            let keyTerminus = offset + currentKeySize
            let currentKey = buffer[offset..<keyTerminus]
            offset += currentKeySize
            
            let bufferTerminus = offset + currentBufferSize
            let currentBuffer = buffer[offset..<bufferTerminus]
            offset += currentBufferSize
            
            keyIndex = offset + 1
            bufferIndex = offset + 2
            offset += 3

            let key = String.fromByteArray(Array(currentKey))
            contents[key] = Array(currentBuffer)
        }
        return contents
    }
}
