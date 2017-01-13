//
//  Reusable.swift
//  Goldfish
//
//  Created by Andrew Cavanagh on 7/19/16.
//  Copyright © 2016 Goldfish. All rights reserved.
//

import Foundation
import UIKit

public protocol Reuseable: class {
    static var reuseIdentifier: String { get }
}
public extension Reuseable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol NibLoadedType {
    static var nibName: String { get }
}
public extension NibLoadedType {
    public static var nibName: String {
        return String(describing: self)
    }
}
public extension NibLoadedType where Self: AnyObject {
    public static func loadFromNib() -> Self {
        guard let view = Bundle(for: self).loadNibNamed(Self.nibName, owner: nil, options: nil)?.first as? Self else {
            fatalError("Misconfigured NibLoadedType \(Self.nibName)")
        }
        return view
    }
}
public extension NibLoadedType where Self: UIViewController {
    public static func loadFromNib() -> Self {
        return Self(nibName: Self.nibName, bundle: Bundle(for: self))
    }
}

public protocol Createable {
    static func create() -> Self
    init()
}
public extension Createable {
    public static func create() -> Self {
        return Self.init()
    }
}

public protocol ReuseableNib: Reuseable, Createable, NibLoadedType {}

public protocol ReuseableView: Reuseable, Createable {
    init()
}

public extension Reuseable where Self: ReuseableNib {
    public static func create() -> Self {
        return loadFromNib()
    }
}

public extension Reuseable where Self: ReuseableView {
    public static func create() -> Self {
        return Self.init()
    }
}
