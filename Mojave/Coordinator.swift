//
//  Coordinator.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/9/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import Foundation

public protocol CoordinatorDelegate: class {
    var coordinatingViewController: UIViewController { get }
    var dataSourceCollection: DataSourceCollection { get }
}

public protocol Coordinator: class, DataSourceDelegate {
    var dataSource: DataSource { get set }
    var dispatcher: Dispatcher { get }
    var sizeCache: SectionedSizeCache { get }

    weak var delegate: CoordinatorDelegate? { get set }

    func update<T: DataSourceModel>(model: T, indexPath: IndexPath, mutation: (inout T) -> Void) -> DataSourceChangeset
    func imperativeUpdate<T: DataSourceModel>(model: T, indexPath: IndexPath)
    func insert<T>(modelCollection: [T], atEndOfSection section: Int, with viewStateBuilder: (T) -> DataSourceModel) -> DataSourceChangeset
    func insert(sections: [DataSourceSection], at section: Int) -> DataSourceChangeset
    func removeAllSections()
    func reload(with state: DataSourceState)

    func size(for indexPath: IndexPath, maxSize: CGSize, descriptor: Descriptor) -> CGSize
}

public extension DataSourceState {
    func nextIndexPath(for section: Int) -> IndexPath {
        return IndexPath(item: numberOfItems(in: section), section: section)
    }
}

public extension DataSourceModel {
    func mutate(_ mutate: (inout Self) -> Void) -> Self {
        var _self = self
        mutate(&_self)
        return _self
    }
}

public extension Coordinator {
    func update<T: DataSourceModel>(model: T, indexPath: IndexPath, mutation: (inout T) -> Void) -> DataSourceChangeset {
        sizeCache.invalidate(indexPath: indexPath)
        let newModel = model.mutate(mutation)
        let changeset = DataSourceChangeset.with(updatedItems: [indexPath : newModel])
        return changeset
    }

    func imperativeUpdate<T: DataSourceModel>(model: T, indexPath: IndexPath) {
        sizeCache.invalidate(indexPath: indexPath)
        dataSource.state.sections[indexPath.section].items[indexPath.item] = model
    }

    func insert(sections: [DataSourceSection], at section: Int) -> DataSourceChangeset {
        var nextSection = section
        var changeset = DataSourceChangeset.empty

        for section in sections {
            changeset.append(insertedSections: [nextSection : section])
            nextSection += 1
        }
        return changeset
    }

    func insert<T>(modelCollection: [T], atEndOfSection section: Int, with viewStateBuilder: (T) -> DataSourceModel) -> DataSourceChangeset {
        var indexPathItemIndex = dataSource.state.nextIndexPath(for: section).item
        var changeset = DataSourceChangeset.empty

        for item in modelCollection {
            let insertionIndexPath = IndexPath(item: indexPathItemIndex, section: section)
            let insertionModel = viewStateBuilder(item)
            indexPathItemIndex += 1

            changeset.append(insertedItems: [insertionIndexPath : insertionModel])
        }
        return changeset
    }

    func reload(with state: DataSourceState) {
        if let collectionView = delegate?.dataSourceCollection {
            sizeCache.invalidateAll()
            dataSource.state = state
            collectionView.reloadData()
        }
    }

    func removeAllSections() {
        guard dataSource.state.numberOfSections > 0 else { return }
        sizeCache.invalidateAll()
        let endIndex = dataSource.state.numberOfSections
        let sections = IndexSet(integersIn: Range(uncheckedBounds: (0, endIndex)))
        let change = DataSourceChangeset.with(removedSections: sections)
        dataSource.apply(changeset: change)
    }

    public func size(for indexPath: IndexPath, maxSize: CGSize, descriptor: Descriptor) -> CGSize {
        if let cachedSize = sizeCache.size(for: indexPath) {
            return cachedSize
        }
        let newSize = descriptor.size(for: dataSource.state.item(at: indexPath),
                                      at: indexPath,
                                      maxSize: maxSize,
                                      coordinator: self)
        sizeCache.cache(size: newSize, for: indexPath)
        return newSize
    }
}

public extension DataSourceDelegate where Self: Coordinator {
    var dataSourceCollection: DataSourceCollection? {
        return delegate?.dataSourceCollection
    }
    func dataSource(_ dataSource: DataSource, didModify previousState: DataSourceState, with changes: DataSourceAppliedChanges) {}
}
