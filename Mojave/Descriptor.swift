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

    func size(for model: DataSourceModel,
                at indexPath: IndexPath,
                maxSize: CGSize,
                coordinator: Coordinator) -> CGSize
    
    func cell(for model: DataSourceModel,
              at indexPath: IndexPath,
              in collectionView: UICollectionView,
              coordinator: Coordinator) -> UICollectionViewCell
}

public extension Descriptor {
    func viewSize<T: ComponentView>(for model: T.Component, viewType: T.Type, maxSize: CGSize) -> CGSize where T: UIView {
        let cell = cellCache.cell(for: GenericCell<T>.self)
        cell.configure(with: model, maxSize: maxSize, dispatcher: nil)
        return cell.size()
    }

    func configuredCell<T: ComponentView>(_ model: T.Component,
                        _ viewType: T.Type,
                        _ collectionView: UICollectionView,
                        _ indexPath: IndexPath,
                        _ coordinator: Coordinator) -> GenericCell<T> {
        let cell = collectionView.dequeue(forIndexPath: indexPath) as GenericCell<T>
        cell.configure(with: model, dispatcher: coordinator.dispatcher)
        return cell
    }
}
