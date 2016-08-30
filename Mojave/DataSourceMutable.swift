//
//  DataSourceMutable.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/27/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

struct DataSourceChange {
    let state: DataSourceState
    let appliedChanges: DataSourceAppliedChanges
}

protocol DataSourceMutable {
    func change(from oldState: DataSourceState) -> DataSourceChange
}

struct DataSourceChangesetModification: DataSourceMutable {
    private let changeset: DataSourceChangeset
    
    init(changeset: DataSourceChangeset) {
        self.changeset = changeset
    }
    
    func change(from oldState: DataSourceState) -> DataSourceChange {
        // state copy
        var sections = oldState.sections
        
        // update items
        for updatedItem in changeset.updatedItems {
            sections[updatedItem.key.section].items[updatedItem.key.item] = updatedItem.value
        }
        
        // move items
        let movedInsertions = changeset.movedItems.map { $0.key }
        let movedDeletions = changeset.movedItems.map { $0.value }
        
        // remove items
        movedDeletions.sorted().lazy.reversed().forEach {
            sections[$0.section].items.remove(at: $0.item)
        }
        changeset.removedItems.sorted().lazy.reversed().forEach {
            sections[$0.section].items.remove(at: $0.item)
        }
        
        // remove sections
        for sectionIndex in changeset.removedSections.reversed() {
            sections.remove(at: sectionIndex)
        }
        
        // insert sections
        for sectionIndex in changeset.insertedSections.reversed() {
            sections.insert(DataSourceSection(), at: sectionIndex)
        }
        
        // insert items
        
        let sortedInsertions = changeset.insertedItems.sorted {
            if $0.key.section == $1.key.section {
                return $0.key.item < $1.key.item
            } else {
                return $0.key.section < $1.key.section
            }
        }
        movedInsertions.sorted().lazy.reversed().forEach {
            sections[$0.section].items.insert(oldState.sections[$0.section].items[$0.item], at: $0.item)
        }
        for insertion in sortedInsertions {
            sections[insertion.key.section].items.insert(insertion.value, at: insertion.key.item)
        }
        
        // return new state
        let newState = DataSourceState(sections: sections)
        let appliedChanges = DataSourceAppliedChanges(updatedIndexPaths: Set(changeset.updatedItems.keys),
                                                      removedIndexPaths: changeset.removedItems,
                                                      removedSections: changeset.removedSections,
                                                      movedIndexPaths: changeset.movedItems,
                                                      insertedSections: changeset.insertedSections,
                                                      insertedIndexPaths: Set(changeset.insertedItems.keys))
        
        return DataSourceChange(state: newState, appliedChanges: appliedChanges)
    }
}
