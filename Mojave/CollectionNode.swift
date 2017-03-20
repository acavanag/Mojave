//
//  DataSourceCollection.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 3/19/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import UIKit

public class CollectionNode: DataSourceCollection {
    public let node: UICollectionView

    public init(node: UICollectionView) {
        self.node = node
    }

    public func deleteSections(_ sections: IndexSet) {
        node.deleteSections(sections)
    }

    public func insertSections(_ sections: IndexSet) {
        node.insertSections(sections)
    }

    public func deleteItems(at indexPaths: [IndexPath]) {
        node.deleteItems(at: indexPaths)
    }

    public func insertItems(at indexPaths: [IndexPath]) {
        node.insertItems(at: indexPaths)
    }

    public func reloadItems(at indexPaths: [IndexPath]) {
        node.reloadItems(at: indexPaths)
    }

    public func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        node.performBatchUpdates(updates, completion: completion)
    }

    public func reloadData() {
        node.reloadData()
    }
}
