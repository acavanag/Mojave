//
//  SectionedSizeCache.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/9/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import Foundation

public final class SectionedSizeCache {
    private var sizeCache = [Int : [Int : CGSize]]()

    public init() {}

    public func size(for indexPath: IndexPath) -> CGSize? {
        return sizeCache[indexPath.section]?[indexPath.item]
    }

    public func invalidateAll() {
        sizeCache.removeAll(keepingCapacity: true)
    }

    public func invalidate(section: Int) {
        sizeCache[section]?.removeAll(keepingCapacity: false)
    }

    public func invalidate(indexPath: IndexPath) {
        _ = sizeCache[indexPath.section]?.removeValue(forKey: indexPath.item)
    }

    public func cache(size: CGSize, for indexPath: IndexPath) {
        if sizeCache[indexPath.section] == nil {
            sizeCache[indexPath.section] = [Int : CGSize]()
        }
        sizeCache[indexPath.section]![indexPath.item] = size
    }
}
