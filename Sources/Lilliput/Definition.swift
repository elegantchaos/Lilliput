// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct LocationPair {
    let id: String
    let position: Position
    
    init(location: String, position: Position) {
        self.id = location
        self.position = position
    }
    
    init?(from spec: Any?) {
        guard let spec = spec else { return nil }
        
        if let dictionary = spec as? [String:String], let idString = dictionary[.locationKey], let posString = dictionary[.positionKey], let pos = Position(rawValue: posString) {
            id = idString
            position = pos
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

extension LocationPair: Comparable {
    static func < (lhs: LocationPair, rhs: LocationPair) -> Bool {
        if lhs.id == rhs.id {
            return lhs.position < rhs.position
        } else {
            return lhs.id < rhs.id
        }
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
    let handlers: Handlers
    
    init(id: String, properties: [String:Any]) {
        self.id = id
        self.properties = properties
        
        self.handlers = Handlers(from: properties["handlers"])
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

