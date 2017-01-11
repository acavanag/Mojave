//
//  GenericCell.swift
//  Goldfish
//
//  Created by Andrew Cavanagh on 1/10/17.
//  Copyright © 2017 Goldfish. All rights reserved.
//

import UIKit
import Mojave

public protocol Component: DataSourceModel {
    associatedtype View

    func configure(for view: View, with dispatcher: Dispatcher?)
    func height(for view: View) -> CGFloat
}

public class GenericCell<T: Component>: UICollectionViewCell, Reuseable where T.View: UIView {
    private let componentView = T.View()
    private var maxWidth: CGFloat = 0

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentView.addAndPin(subview: componentView)
        contentView.backgroundColor = .blue
    }

    public func configure(with component: T, maxWidth: CGFloat = 0, dispatcher: Dispatcher? = nil) {
        self.maxWidth = maxWidth
        component.configure(for: componentView, with: dispatcher)
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

    public func height(with component: T) -> CGFloat {
        return component.height(for: componentView)
    }
}
