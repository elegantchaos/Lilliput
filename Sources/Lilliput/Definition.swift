// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Definition {
    let id: String
    let strings: [String:String]
    let properties: [String:Any]
    let names: [String]
    let exits: [String:String]
    let kind: String
    
    init(id: String, properties: [String:Any]) {
        self.id = id
        self.properties = properties
        
        self.strings = (properties["descriptions"] as? [String:String]) ?? [:]
        self.names = (properties["names"] as? [String]) ?? []
        self.exits = (properties["exits"] as? [String:String]) ?? [:]
        self.kind = properties[stringWithKey: "type"] ?? "object"
    }
    
    func hasFlag(_ key: String) -> Bool {
        guard let value = properties[key] as? Bool else { return false }
        return value
    }
}

