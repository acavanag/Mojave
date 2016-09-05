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
    
    public init() {}
    
    public func archive<T: Cacheable>(_ object: T, to url: URL, with completion: (@escaping (Bool) -> Void)? = nil) {
        archiveQueue.async {
            do {
                try self.sync_archive(object: object, url: url)
                guard let completion = completion else { return }
                DispatchQueue.main.async { completion(true) }
            } catch {
                guard let completion = completion else { return }
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    public func async_unarchive<T: Cacheable>(_ url: URL, of type: T.Type, with completion: @escaping (T?) -> Void) {
        archiveQueue.async {
            do {
                let data = try Data(contentsOf: url)
                let coder = Coder(values: Coder.decode(from: data))
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
        let coder = Coder()
        object.encode(with: coder)
        
        try coder.encodeToData().write(to: url)
    }
}
