//
//  Archiver.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/4/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation

public final class Archiver {
    private let archiveQueue = DispatchQueue(label: "archiveQueue")
    
    public func async_archive<T: Cacheable>(_ object: T, to url: URL, with completion: @escaping (Bool) -> Void) {
        archiveQueue.async {
            do {
                try self.sync_archive(object: object, url: url)
                DispatchQueue.main.async { completion(true) }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    public func async_unarchive<T: Cacheable>(_ url: URL, of type: T.Type, with completion: @escaping (T?) -> Void) {
        archiveQueue.async {
            do {
                let data = try Data(contentsOf: url)
                let coder = Coder.decode(data: data)
                let object = T(with: coder)
                DispatchQueue.main.async { completion(object) }
            } catch {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}

fileprivate extension Archiver {
    func sync_archive<T: Cacheable>(object: T, url: URL) throws {
        let coder = Coder(type: type(of: object))
        object.encode(with: coder)
        
        try coder.encode().write(to: url)
    }
}
