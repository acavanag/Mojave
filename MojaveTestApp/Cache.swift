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
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func encode(with coder: Coder) {
        coder.encode(name, for: "name")
    }
    
    init?(with coder: Coder) {
        name = coder.decode(for: "name")!
    }
}
