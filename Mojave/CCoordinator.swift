//
//  CCoordinator.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 3/19/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import Foundation

open class CCoordinator: Coordinator, DataSourceDelegate {
    public var collection: DataSourceCollection?
    public var dataSource: DataSource
    public var dispatcher = Dispatcher()
    public var sizeCache = SectionedSizeCache()
    weak public var delegate: CoordinatorDelegate?

    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

}
