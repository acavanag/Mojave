//
//  Layout.swift
//  Goldfish
//
//  Created by Andrew Cavanagh on 7/19/16.
//  Copyright © 2016 Goldfish. All rights reserved.
//

import CoreGraphics
import UIKit

/// A type that can layout itself and its contents.
public protocol Layout {
    /// Lay out this layout and all of its contained layouts within `rect`.
    mutating func layout(in rect: CGRect)

    /// The type of the leaf content elements in this layout.
    associatedtype Content

    /// Return all of the leaf content elements contained in this layout and its descendants.
    var contents: [Content] { get }
}

extension UIView: Layout {
    public typealias Content = UIView

    public func layout(in rect: CGRect) {
        frame = rect
    }

    func layout(maxWidth: CGFloat) {
        frame = CGRect(x: frame.origin.x,
                       y: frame.origin.y,
                       width: maxWidth,
                       height: frame.size.height)
    }

    public var contents: [Content] {
        return [self]
    }
}
