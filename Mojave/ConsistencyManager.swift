//
//  ConsistencyManager.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 8/30/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public enum ConsistencyManagerError: Error {
    case alreadyRegistered
    case notRegistered
}

public protocol ConsistencyManagerListener: class {
    func manager<T: DataSourceModel>(_ manager: ConsistencyManager, didUpdate modelType: T.Type, with model: T)
    func manager<T: DataSourceModel>(_ manager: ConsistencyManager, registered modelType: T.Type, with model: T)
    func listen<T: DataSourceModel>(to model: T.Type)
}

public extension ConsistencyManagerListener {
    func listen<T: DataSourceModel>(to modelType: T.Type) {
        ConsistencyManager.add(listener: self, for: modelType)
    }
    func manager<T: DataSourceModel>(_ manager: ConsistencyManager, didUpdate modelType: T.Type, with model: T) {}
    func manager<T: DataSourceModel>(_ manager: ConsistencyManager, registered modelType: T.Type, with model: T) {}
}

fileprivate enum ConsistencyManagerEvent {
    case update, new
}

public final class ConsistencyManager {
    private let queue = DispatchQueue(label: "mojave.consistencyManager")
    private var listeners = [String : NSHashTable<AnyObject>]()
    private var models = [String : DataSourceModel]()
    
    fileprivate static let sharedInstance = ConsistencyManager()
    
    internal init() {}
    
    internal func isRegistered<T: DataSourceModel>(model: T.Type) -> Bool {
        return models[model.__identifier] != nil
    }
    
    internal func registerShared<T: DataSourceModel>(model: T) throws {
        guard models[model._identifier] == nil else { throw ConsistencyManagerError.alreadyRegistered }
        models[model._identifier] = model
        notify(with: model, event: .new)
    }
    
    internal func updateShared<T: DataSourceModel>(model: T) throws {
        guard let _model = models[model._identifier] else { throw ConsistencyManagerError.notRegistered }
        models[_model._identifier] = model
        notify(with: model, event: .update)
    }
    
    internal func model<T: DataSourceModel>(forShared modelType: T.Type) -> T? {
        guard let sharedModel = models[modelType.__identifier] as? T else { return nil }
        return sharedModel
    }
    
    internal func add<T: DataSourceModel>(listener: ConsistencyManagerListener, for modelType: T.Type) {
        dispatch_async_safe_main_queue {
            if self.listeners[modelType.__identifier] == nil {
                self.listeners[modelType.__identifier] = NSHashTable(options: .weakMemory)
            }
            
            self.listeners[modelType.__identifier]!.add(listener)
        }
    }
    
    private func notify<T: DataSourceModel>(with model: T, event: ConsistencyManagerEvent) {
        dispatch_async_safe_main_queue {
            guard let newModel = self.models[model._identifier] as? T else { fatalError("Misconfigured ConsistencyManager") }
            guard let listeners = self.listeners[model._identifier] else { return }
            
            let enumerator = listeners.objectEnumerator()
            while let listener: Any = enumerator.nextObject() {
                if let listener = listener as? ConsistencyManagerListener {
                    switch event {
                    case .update:
                        listener.manager(self, didUpdate: T.self, with: newModel)
                    case .new:
                        listener.manager(self, registered: T.self, with: newModel)
                    }
                }
            }
        }
    }
}

extension ConsistencyManager {
    public static func isRegistered<T: DataSourceModel>(modelType: T.Type) -> Bool {
        return sharedInstance.isRegistered(model: modelType)
    }
    public static func registerShared<T: DataSourceModel>(model: T) throws {
        try sharedInstance.registerShared(model: model)
    }
    public static func updateShared<T: DataSourceModel>(model: T) throws {
        try sharedInstance.updateShared(model: model)
    }
    public static func model<T: DataSourceModel>(forShared modelType: T.Type) -> T? {
        return sharedInstance.model(forShared: modelType)
    }
    public static func add<T: DataSourceModel>(listener: ConsistencyManagerListener, for modelType: T.Type) {
        sharedInstance.add(listener: listener, for: modelType)
    }
}
