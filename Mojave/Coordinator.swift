//
//  Coordinator.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/9/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import Foundation

public protocol CoordinatorDelegate: class {
    func didUpdateViewState(at indexPath: IndexPath)
    var coordinatingViewController: UIViewController { get }
    var dataSourceCollectionView: UICollectionView { get }
}

public protocol Coordinator: class, DataSourceDelegate {
    var dataSource: DataSource { get set }
    weak var delegate: CoordinatorDelegate? { get set }
    func mutate<T: DataSourceModel>(type: T.Type, indexPath: IndexPath, mutation: (inout T) -> Void)
    func update<T: DataSourceModel>(model: T, indexPath: IndexPath, mutation: (inout T) -> Void) -> DataSourceChangeset
    func insert<T>(modelCollection: [T], atEndOfSection section: Int, with viewStateBuilder: (T) -> DataSourceModel) -> DataSourceChangeset
    func reload(with state: DataSourceState)
}

public extension DataSourceState {
    func nextIndexPath(for section: Int) -> IndexPath {
        return IndexPath(item: numberOfItems(in: section), section: section)
    }
}

public extension DataSourceModel {
    func mutate(_ mutatePost: (inout Self) -> Void) -> Self {
        var post = self
        mutatePost(&post)
        return post
    }
}

public extension Coordinator {
    func mutate<T: DataSourceModel>(type: T.Type, indexPath: IndexPath, mutation: (inout T) -> Void) {
        if let model = dataSource.state.item(at: indexPath) as? T {
            dataSource.state.sections[indexPath.section].items[indexPath.item] = model.mutate(mutation)
        }
    }

    func update<T: DataSourceModel>(model: T, indexPath: IndexPath, mutation: (inout T) -> Void) -> DataSourceChangeset {
        let newModel = model.mutate(mutation)
        let changeset = DataSourceChangeset.with(updatedItems: [indexPath : newModel])
        return changeset
    }

    func imperativeUpdate<T: DataSourceModel>(model: T, indexPath: IndexPath) {
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
        if let collectionView = delegate?.dataSourceCollectionView {
            dataSource.state = state
            collectionView.reloadData()
        }
    }

    func replaceAllSections(with newSections: [DataSourceSection]) {
        let endIndex = dataSource.state.numberOfSections
        let sections = IndexSet(integersIn: Range(uncheckedBounds: (0, endIndex)))
        var changeset = DataSourceChangeset.with(removedSections: sections)
        var nextSection = 0
        for section in newSections {
            changeset.append(insertedSections: [nextSection : section])
            nextSection += 1
        }
        dataSource.apply(changeset: changeset)
    }

    func removeAllSections() {
        guard dataSource.state.numberOfSections > 0 else { return }
        let endIndex = dataSource.state.numberOfSections
        let sections = IndexSet(integersIn: Range(uncheckedBounds: (0, endIndex)))
        let change = DataSourceChangeset.with(removedSections: sections)
        dataSource.apply(changeset: change)
    }
}

public extension DataSourceDelegate where Self: Coordinator {
    var dataSourceCollectionView: UICollectionView? {
        return delegate?.dataSourceCollectionView
    }
    func dataSource(_ dataSource: DataSource, didModify previousState: DataSourceState, with changes: DataSourceAppliedChanges) {}
}
