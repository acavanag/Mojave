//
//  Utility.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/28/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func append(_ rhs: [Key : Value]) {
        for (k, v) in rhs {
            updateValue(v, forKey: k)
        }
    }
}

extension Set {
    mutating func append(_ rhs: Set<Element>) {
        for e in rhs {
            update(with: e)
        }
    }
}

extension IndexSet {
    mutating func append(_ rhs: IndexSet) {
        for e in rhs {
            update(with: e)
        }
    }
}

func dispatch_async_safe_main_queue(_ block: @escaping () -> Void) {
    Thread.isMainThread ? block() : DispatchQueue.main.async(execute: block)
}

extension UIView {
    func addAndPin(subview: UIView, insets: UIEdgeInsets = .zero) {
        addSubview(subview)
        pinViews(parentView: self, childView: subview, insets: insets)
    }

    func pinViews(parentView: UIView, childView: UIView, insets: UIEdgeInsets = .zero) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(childView)
        let left = NSLayoutConstraint(item: childView, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: insets.left)
        let top = NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1, constant: insets.top)
        let right  = NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: insets.right)
        let bottom = NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: insets.bottom)
        parentView.addConstraints([left, top, right, bottom])
    }
}

public protocol Measurable {
    func height() -> CGFloat
}

public extension Measurable where Self : UICollectionViewCell {
    func height() -> CGFloat {
        return contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
}

public extension Measurable where Self: UIView {
    func height() -> CGFloat {
        return systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    }
}
