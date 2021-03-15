// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct LocationPair {
    let id: String
    let position: Position
    
    init?(from spec: Any?) {
        guard let spec = spec else { return nil }
        
        if let locAndPos = spec as? [String], locAndPos.count > 1 {
            id = locAndPos[0]
            position = Position(rawValue: locAndPos[1]) ?? .in
        } else if let string = spec as? String {
            id = string
            position = .in
        } else {
            print("Bad location spec: \(spec)")
            return nil
        }
    }
    
    var persistenceData: [String] {
        return [id, position.rawValue]
    }
}

public struct Definition {
    let id: String
    let location: LocationPair?
    let strings: [String:String]
    let properties: [String:Any]
    let names: [String]
    let exits: [String:String]
    let traits: [String]
    let dialogue: [String:Any]?
    let mass: Double
    let volume: Double
    
    init(id: String, properties: [String:Any]) {
        self.id = id
        self.properties = properties
        
        self.location = LocationPair(from: properties["location"])
        self.strings = (properties["descriptions"] as? [String:String]) ?? [:]
        self.names = (properties["names"] as? [String]) ?? []
        self.exits = (properties["exits"] as? [String:String]) ?? [:]
        self.dialogue = properties["dialogue"] as? [String:Any]
        self.mass = properties[asDouble: "mass"] ?? 0
        self.volume = properties[asDouble: "volume"] ?? 0
        
        var traits: [String] = (properties["traits"] as? [String]) ?? []
        if let kind = properties[asString: "type"] {
            traits.append(kind)
        }
        self.traits = traits
    }
    
    func hasFlag(_ key: String) -> Bool {
        guard let value = properties[key] as? Bool else { return false }
        return value
    }
}

