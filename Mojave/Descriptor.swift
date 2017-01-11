//
//  Descriptor.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/10/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import UIKit
import Mojave

public protocol Descriptor {
    var cellCache: GenericCellCache { get }

    func height(for model: DataSourceModel,
                at indexPath: IndexPath,
                maxWidth: CGFloat,
                coordinator: Coordinator) -> CGFloat
    func cell(for model: DataSourceModel,
              at indexPath: IndexPath,
              in collectionView: UICollectionView,
              coordinator: Coordinator,
              maxWidth: CGFloat) -> UICollectionViewCell
}

public extension Descriptor {
    func modelHeight<T: Component>(component: T, maxWidth: CGFloat) -> CGFloat where T.View: UIView {
        let cell = cellCache.cell(for: GenericCell<T>.self)
        cell.configure(with: component, maxWidth: maxWidth, dispatcher: nil)
        return cell.height(with: component)
    }
}
