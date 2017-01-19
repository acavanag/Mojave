//
//  Descriptor.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/10/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import UIKit

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
    func viewHeight<T: ComponentView>(for model: T.Component, viewType: T.Type, maxWidth: CGFloat) -> CGFloat where T: UIView {
        let cell = cellCache.cell(for: GenericCell<T>.self)
        let maxSize = CGSize(width: maxWidth, height: .largeValue)
        cell.configure(with: model, maxSize: maxSize, dispatcher: nil)
        return cell.height()
    }
}
