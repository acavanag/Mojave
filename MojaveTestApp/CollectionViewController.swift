//
//  CollectionViewController.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/28/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import UIKit
import Mojave

private let reuseIdentifier = "Cell"

struct TestModel: DataSourceModel {
    let color: UIColor
}

func after(delayInSeconds: TimeInterval, queue: DispatchQueue = DispatchQueue.main, _ block: @escaping () -> Void) {
    let milliseconds = Int(delayInSeconds * 1000)
    let delayTime = DispatchTime.now() + .milliseconds(milliseconds)
    queue.asyncAfter(deadline: delayTime, execute: block)
}

class CollectionViewController: UICollectionViewController, DataSourceDelegate {

    let archiver = Archiver()
    var dataSource: DataSource
    
    var dataSourceCollectionView: UICollectionView? {
        return collectionView
    }
    
    init() {
        let initialState = DataSourceState(sections: [DataSourceSection(items: [])])
        dataSource = DataSource(initialState: initialState)
        
        super.init(nibName: nil, bundle: nil)
        cacheTests()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let initialState = DataSourceState(sections: [DataSourceSection(items: [])])
        dataSource = DataSource(initialState: initialState)
        
        super.init(coder: aDecoder)
        cacheTests()
    }
    
    func cacheTests() {
        let _url = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = _url.appendingPathComponent("lol_neat")
        let model = Model(name: "Andrew")
        
        after(delayInSeconds: 1) { 
            self.archiver.async_archive(model, to: url) { _ in }
        }
        
        after(delayInSeconds: 3) { 
            self.archiver.async_unarchive(url, of: Model.self, with: { object in
                print(object?.name)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var changeset = DataSourceChangeset.empty
        changeset.append(insertedItems: [IndexPath(item: 0, section: 0) : TestModel(color: .blue)])
        changeset.append(insertedItems: [IndexPath(item: 1, section: 0) : TestModel(color: .red)])
        changeset.append(insertedItems: [IndexPath(item: 2, section: 0) : TestModel(color: .green)])
        changeset.append(insertedItems: [IndexPath(item: 3, section: 0) : TestModel(color: .orange)])
        changeset.append(insertedItems: [IndexPath(item: 4, section: 0) : TestModel(color: .purple)])
        changeset.append(insertedItems: [IndexPath(item: 5, section: 0) : TestModel(color: .yellow)])
        changeset.append(insertedItems: [IndexPath(item: 6, section: 0) : TestModel(color: .brown)])
        changeset.append(insertedItems: [IndexPath(item: 7, section: 0) : TestModel(color: .gray)])
        changeset.append(insertedItems: [IndexPath(item: 8, section: 0) : TestModel(color: .cyan)])
        changeset.append(insertedItems: [IndexPath(item: 8, section: 0) : TestModel(color: .magenta)])
        
        dataSource.apply(changeset: changeset)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.state.numberOfSections
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.state.numberOfItems(in: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let item = dataSource.state.item(at: indexPath)
        
        if let item = item as? TestModel {
            cell.contentView.backgroundColor = item.color
        } else {
            fatalError("INVALID CELL")
        }

        return cell
    }
    
    func dataSource(_ dataSource: DataSource, didModify previousState: DataSourceState, with changes: DataSourceAppliedChanges) {}

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
