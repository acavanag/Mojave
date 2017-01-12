//
//  Dispatcher.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 1/10/17.
//  Copyright © 2017 Andrew Cavanagh. All rights reserved.
//

import Foundation

public protocol EventType {
    static var key: String { get }
}

public extension EventType {
    static var key: String {
        return String(describing: self)
    }
}

private final class Observer<T> {
    let block: (T) -> Void
    init(block: @escaping (T) -> Void) {
        self.block = block
    }
}

/// Dispatcher
/// Maintains a collection of observers indexed by an EventType
public final class Dispatcher {

    private var observers = [String : NSHashTable<AnyObject>]()

    public init() {}

    public func addObserver<T: EventType>(event: T.Type, block: @escaping (T) -> Void) {
        let observer = Observer<T>(block: block)

        if observers[event.key] == nil {
            observers[event.key] = NSHashTable(options: NSPointerFunctions.Options.weakMemory)
        }
        observers[event.key]?.add(observer)
    }

    public func notifyEvent<T: EventType>(event: T) {
        observers[type(of: event).key]?.allObjects.forEach { observer in
            if let casted = observer as? Observer<T> {
                casted.block(event)
            }
        }
    }
    
}
