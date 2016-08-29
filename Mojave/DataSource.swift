//
//  DataSource.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/27/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation
import UIKit

public protocol DataSourceDelegate: class {
    var dataSourceCollectionView: UICollectionView? { get }
    func dataSource(_ dataSource: DataSource, didModify previousState: DataSourceState, with changes: DataSourceAppliedChanges)
}
extension DataSourceDelegate {
    func dataSource(_ dataSource: DataSource, didModify previousState: DataSourceState, with changes: DataSourceAppliedChanges) {}
}

public struct DataSource {
    public weak var delegate: DataSourceDelegate?
    public var state: DataSourceState
    
    public init(initialState: DataSourceState = .empty, delegate: DataSourceDelegate? = nil) {
        self.delegate = delegate
        self.state = initialState
    }
    
    public mutating func apply(changeset: DataSourceChangeset) {
        let previousState = state
        let changes = DataSourceChangesetModification(changeset: changeset).change(from: state)
        state = changes.state

        update(with: changes, from: previousState)
    }
    
    private func update(with change: DataSourceChange, from previous: DataSourceState) {
        guard let collectionView = delegate?.dataSourceCollectionView else { return }
        let appliedChanges = change.appliedChanges
        collectionView.performBatchUpdates({
            if !appliedChanges.removedSections.isEmpty {
                collectionView.deleteSections(appliedChanges.removedSections)
            }
            if !appliedChanges.insertedSections.isEmpty {
                collectionView.insertSections(appliedChanges.insertedSections)
            }
            if !appliedChanges.removedIndexPaths.isEmpty {
                collectionView.deleteItems(at: Array(appliedChanges.removedIndexPaths))
            }
            if !appliedChanges.updatedIndexPaths.isEmpty {
                collectionView.reloadItems(at: Array(appliedChanges.updatedIndexPaths))
            }
            if !appliedChanges.insertedIndexPaths.isEmpty {
                collectionView.insertItems(at: Array(appliedChanges.insertedIndexPaths))
            }
        }) { _ in
            self.delegate?.dataSource(self, didModify: previous, with: appliedChanges)
        }
    }
}
