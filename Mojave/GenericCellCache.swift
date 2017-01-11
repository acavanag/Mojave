//
//  CellCache.swift
//  Goldfish
//
//  Created by Andrew Cavanagh on 1/11/17.
//  Copyright © 2017 Goldfish. All rights reserved.
//

import UIKit

public final class GenericCellCache {

    private var cellCache = [String : UICollectionViewCell]()

    public init() {}

    public func cache<T: Component>(cell: GenericCell<T>) {
        guard let identifier = cell.reuseIdentifier else { return }
        cellCache[identifier] = cell
    }

    public func cell<T: Component>(for cellType: GenericCell<T>.Type) -> GenericCell<T> {
        if let cachedCell = cellCache[cellType.reuseIdentifier] as? GenericCell<T> {
            return cachedCell
        }

        let cell = GenericCell<T>()
        cache(cell: cell)
        return cell
    }

    public func invalidateAll() {
        cellCache.removeAll(keepingCapacity: true)
    }

    public func invalidate(identifier: String) {
        cellCache[identifier] = nil
    }

}
