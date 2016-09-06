//
//  Cacheable.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/3/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public typealias Values = [String : [UInt8]]

public enum CacheableError: Error {
    case invalidDecode
}

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
    
    public func encode<T: ByteRepresentable>(_ value: [T], for key: String) {
        var buffer = [UInt8]()
        for v in value {
            let valueBuffer = v.toByteArray()
            let valueBufferSize = valueBuffer.count.toByteArray()
            
            buffer.append(contentsOf: valueBufferSize)
            buffer.append(contentsOf: valueBuffer)
        }
        values[key] = buffer
    }
    
    public func encode<T: Cacheable>(_ value: [T], for key: String) {
        var buffer = [UInt8]()
        for v in value {
            let coder = Coder()
            v.encode(with: coder)
            let valuesBuffer = coder.encodeValues()
            let valuesBufferSize = valuesBuffer.count.toByteArray()
            
            buffer.append(contentsOf: valuesBufferSize)
            buffer.append(contentsOf: valuesBuffer)
        }
        values[key] = buffer
    }
    
    public func encode<T: Cacheable>(_ value: T, for key: String) {
        let coder = Coder()
        value.encode(with: coder)
        values[key] = coder.encodeValues()
    }
    
    public func decode<T: ByteRepresentable>(for key: String) throws -> T {
        guard let value = values[key] else { throw CacheableError.invalidDecode }
        return Coder.fromByteArray(value, T.self)
    }

    public func decode<T: Cacheable>(for key: String) throws -> T {
        guard let value = values[key] else { throw CacheableError.invalidDecode }
        let childValues = Coder.decodeValues(value)
        let coder = Coder(values: childValues)
        guard let object = T(with: coder) else { throw CacheableError.invalidDecode }
        return object
    }
    
    public func decode<T: Cacheable>(for key: String) throws -> [T] {
        guard let value = values[key] else { throw CacheableError.invalidDecode }

        var collection = [T]()
        var offset = 0
        while offset < value.count {
            let bufferSizeTerminus = offset + 8
            let bufferSize = Int.fromByteArray(Array(value[offset..<bufferSizeTerminus]))
            
            offset = bufferSizeTerminus
            let bufferTerminus = offset + bufferSize
            let buffer = Array(value[offset..<bufferTerminus])
            offset = bufferTerminus
            
            let childValues = Coder.decodeValues(buffer)
            let coder = Coder(values: childValues)
            if let object = T(with: coder) {
                collection.append(object)
            }
        }
        
        return collection
    }
    
    public func decode<T: ByteRepresentable>(for key: String) throws -> [T] {
        guard let value = values[key] else { throw CacheableError.invalidDecode }
        
        var collection = [T]()
        var offset = 0
        while offset < value.count {
            let bufferSizeTerminus = offset + 8
            let bufferSize = Int.fromByteArray(Array(value[offset..<bufferSizeTerminus]))
            
            offset = bufferSizeTerminus
            let bufferTerminus = offset + bufferSize
            let buffer = Array(value[offset..<bufferTerminus])
            offset = bufferTerminus
            
            let object = Coder.fromByteArray(buffer, T.self)
            collection.append(object)
        }
        
        return collection
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
            let keyBufferSize = keyBuffer.count.toByteArray()
            let bufferSize = buffer.count.toByteArray()
            valueBuffer.append(contentsOf: keyBufferSize)
            valueBuffer.append(contentsOf: bufferSize)
            valueBuffer.append(contentsOf: keyBuffer)
            valueBuffer.append(contentsOf: buffer)
        }
        return valueBuffer
    }
    
    static func decodeValues(_ buffer: [UInt8]) -> Values {
        var contents = Values()
        
        var offset = 16
        var keyIndex = 0
        var bufferIndex = 8
        
        while offset < buffer.count {
            let currentKeySizeTerminus = keyIndex + 8
            let currentKeySize = Int.fromByteArray(Array(buffer[keyIndex..<currentKeySizeTerminus]))
            
            let currentBufferSizeTerminus = bufferIndex + 8
            let currentBufferSize = Int.fromByteArray(Array(buffer[bufferIndex..<currentBufferSizeTerminus]))
            
            let keyTerminus = offset + currentKeySize
            let currentKey = buffer[offset..<keyTerminus]
            offset += currentKeySize
            
            let bufferTerminus = offset + currentBufferSize
            let currentBuffer = buffer[offset..<bufferTerminus]
            offset += currentBufferSize
            
            keyIndex = offset
            bufferIndex = keyIndex + 8
            offset = bufferIndex + 8

            let key = String.fromByteArray(Array(currentKey))
            contents[key] = Array(currentBuffer)
        }
        
        return contents
    }
}
