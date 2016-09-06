//
//  Cache.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/4/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation
import Mojave

struct Wat: Cacheable {
    let id: Int
    let path: String
    
    init(id: Int, path: String) {
        self.id = id
        self.path = path
    }
    
    func encode(with coder: Coder) {
        coder.encode(id, for: "id")
        coder.encode(path, for: "path")
    }
    
    init?(with coder: Coder) {
        do {
            id = try coder.decode(for: "id")
            path = try coder.decode(for: "path")
        } catch { return nil }
    }
}

struct Model: Cacheable {
    let id: Int
    let name: String
    let date : Date
    let fav: Bool
    let wat: Wat
    
    init(id: Int, name: String, date: Date, fav: Bool, wat: Wat) {
        self.id = id
        self.name = name
        self.date = date
        self.fav = fav
        self.wat = wat
    }
    
    func encode(with coder: Coder) {
        coder.encode(id, for: "id")
        coder.encode(name, for: "name")
        coder.encode(date, for: "date")
        coder.encode(fav, for: "fav")
        coder.encode(wat, for: "wat")
        
        let nums = [1,2,3]
        coder.encode(nums, for: "nums")
    }
    
    init?(with coder: Coder) {
        do {
            id = try coder.decode(for: "id")
            name = try coder.decode(for: "name")
            date = try coder.decode(for: "date")
            fav = try coder.decode(for: "fav")
            wat = try coder.decode(for: "wat")
        } catch { return nil }
    }
}
