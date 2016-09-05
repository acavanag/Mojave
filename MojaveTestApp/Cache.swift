//
//  Cache.swift
//  Mojave
//
//  Created by Andrew Cavanagh on 9/4/16.
//  Copyright © 2016 Andrew Cavanagh. All rights reserved.
//

import Foundation
import Mojave

struct Model: Cacheable {
    let id: Int
    let name: String
    let date : Date
    let fav: Bool
    
    init(id: Int, name: String, date: Date, fav: Bool) {
        self.id = id
        self.name = name
        self.date = date
        self.fav = fav
    }
    
    func encode(with coder: Coder) {
        coder.encode(id, for: "id")
        coder.encode(name, for: "name")
        coder.encode(date, for: "date")
        coder.encode(fav, for: "fav")
    }
    
    init?(with coder: Coder) {
        do {
            id = try coder.decode(for: "id")
            name = try coder.decode(for: "name")
            date = try coder.decode(for: "date")
            fav = try coder.decode(for: "fav")
        } catch { return nil }
    }
}
