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
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    func encode(with coder: Coder) {
        coder.encode(id, for: "id")
        coder.encode(name, for: "name")
    }
    
    init?(with coder: Coder) {
        id = coder.decode(for: "id")!
        name = coder.decode(for: "name")!
    }
}
