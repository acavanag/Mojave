//
//  ByteRepresentable.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/4/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public typealias Bytes = [UInt8]

public protocol ByteRepresentable {
    func toByteArray() -> [UInt8]
    static func fromByteArray(_ buffer: [UInt8]) -> Self
}

public extension ByteRepresentable {
    func toByteArray() -> [UInt8] {
        return Coder.toByteArray(self)
    }
    static func fromByteArray(_ buffer: [UInt8]) -> Self {
        return Coder.fromByteArray(buffer, Self.self)
    }
}

extension Int: ByteRepresentable {}
extension Double: ByteRepresentable {}
extension Float: ByteRepresentable {}
extension CGFloat: ByteRepresentable {}
extension Date: ByteRepresentable {}

extension String: ByteRepresentable {
    public func toByteArray() -> [UInt8] {
        return utf8CString.map { UInt8($0) }
    }
    public static func fromByteArray(_ buffer: [UInt8]) -> String {
        return String(cString: buffer)
    }
}
