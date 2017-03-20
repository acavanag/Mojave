//
//  Model.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/27/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public protocol DataSourceModel {}

extension DataSourceModel {
    static var __identifier: String {
        return String(describing: self)
    }
    public var _identifier: String {
        return type(of: self).__identifier
    }
}
