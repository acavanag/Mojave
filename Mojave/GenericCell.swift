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

    func configure(with model: Component, dispatcher: Dispatcher?)
}

public class GenericCell<T: ComponentView>: UICollectionViewCell, Reuseable where T: UIView {
    private let componentView = T.create()
    private var maxWidth: CGFloat = 0

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentView.addAndPin(subview: componentView)
    }

    public func configure(with component: T.Component, maxWidth: CGFloat = 0, dispatcher: Dispatcher? = nil) {
        self.maxWidth = maxWidth
        componentView.configure(with: component, dispatcher: dispatcher)
        componentView.setNeedsLayout()
        componentView.layoutIfNeeded()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        componentView.layout(maxWidth: maxWidth)
        super.layoutSubviews()
    }

    public func height() -> CGFloat {
        return componentView.height()
    }
}
