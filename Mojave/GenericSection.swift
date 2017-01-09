//
//  GenericSection.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/9/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import Foundation

public struct GenericSection: DataSourceSection {
    public var items: [DataSourceModel]

    public init(items: [DataSourceModel] = []) {
        self.items = items
    }
}
