//
//  DataSourceState.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/27/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public struct DataSourceState {
    public var sections: [DataSourceSection]
    
    public init(sections: [DataSourceSection]) {
        self.sections = sections
    }
    
    public var numberOfSections: Int {
        return sections.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard numberOfSections > 0 else { return 0 }
        return sections[section].items.count
    }
    
    public func section(at index: Int) -> DataSourceSection {
        return sections[index]
    }
    
    public func item(at indexPath: IndexPath) -> DataSourceModel {
        return sections[indexPath.section].items[indexPath.item]
    }
    
    public func enumerate(block: (_ : DataSourceModel, _ : IndexPath, _ : inout Bool) -> Void) {
        var stop = false
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                block(item, IndexPath(item: itemIndex, section: sectionIndex), &stop)
                if stop { return }
            }
        }
    }
    
    public func enumerate(section: Int, block: (_ : DataSourceModel, _ : IndexPath, _ : inout Bool) -> Void) {
        var stop = false
        for (index, item) in sections[section].items.enumerated() {
            block(item, IndexPath(item: index, section: section), &stop)
            if stop { return }
        }
    }
}

extension DataSourceState {
    public static var empty: DataSourceState {
        return DataSourceState(sections: [])
    }
}
