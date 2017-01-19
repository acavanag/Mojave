//
//  GenericCell.swift
//  Goldfish
//
//  Created by Andrew Cavanagh on 1/10/17.
//  Copyright © 2017 Goldfish. All rights reserved.
//

import UIKit

public protocol ComponentView: Createable, Measurable {
    associatedtype Component

    func configure(with model: Component, maxSize: CGSize, dispatcher: Dispatcher?)
}

public class GenericCell<T: ComponentView>: UICollectionViewCell, Reuseable where T: UIView {
    private let componentView = T.create()
    private var maxSize: CGSize = .zero

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentView.addAndPin(subview: componentView)
    }

    public func configure(with component: T.Component, maxSize: CGSize = .zero, dispatcher: Dispatcher? = nil) {
        self.maxSize = maxSize
        componentView.configure(with: component, maxSize: maxSize, dispatcher: dispatcher)
        componentView.setNeedsLayout()
        componentView.layoutIfNeeded()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func height() -> CGFloat {
        return componentView.height()
    }
}
