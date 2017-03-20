//
//  CController.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 3/19/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import UIKit

open class CController<C: Coordinator, D: Descriptor>: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public let coordinator: C
    public let descriptor: D
    public let collection: CollectionNode

    public init(descriptor: D, coordinator: C, collectionViewLayout: UICollectionViewLayout) {
        self.coordinator = coordinator
        self.descriptor = descriptor

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.alwaysBounceVertical = true
        collection = CollectionNode(node: collectionView)

        super.init(nibName: nil, bundle: nil)

        collection.node.dataSource = self
        collection.node.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        coordinator.delegate = self
        coordinator.dataSource.delegate = coordinator
        view.addAndPin(subview: collection.node)
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return coordinator.dataSource.state.numberOfSections
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coordinator.dataSource.state.numberOfItems(in: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return descriptor.cell(for: coordinator.dataSource.state.item(at: indexPath),
                               at: indexPath,
                               in: collectionView,
                               coordinator: coordinator)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxSize = CGSize(width: collectionView.bounds.size.width, height: .largeValue)
        return coordinator.size(for: indexPath, maxSize: maxSize, descriptor: descriptor)
    }

    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.coordinator.sizeCache.invalidateAll()
    }
}

// MARK: - Coordinator Delegate

extension CController: CoordinatorDelegate {
    public var coordinatingViewController: UIViewController {
        return self
    }

    public var dataSourceCollection: DataSourceCollection {
        return collection
    }
}
