// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct LocationPair {
    public let id: String
    public let position: Position
    
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

public struct StringTable {
    typealias Index = [String:StringAlternatives]
    let table: Index
    
    var keys: Index.Keys {
        table.keys
    }
    
    init(from data: Any?) {
        var filtered: Index = [:]
        if let items = (data as? [String:Any]) {
            for item in items {
                if let strings = StringAlternatives(item.value) {
                    filtered[item.key] = strings
                }
            }
        }
        table = filtered
    }
    
    func alternatives(for key: String) -> StringAlternatives? {
        return table[key]
    }
}

public struct StringAlternatives {
    let strings: [String]
    
    init?(_ data: Any?) {
        if let string = data as? String {
            self.strings = [string]
        } else if let strings = data as? [String] {
            self.strings = strings
        } else {
            return nil
        }
    }
}

extension LocationPair: Comparable {
    public static func < (lhs: LocationPair, rhs: LocationPair) -> Bool {
        if lhs.id == rhs.id {
            return lhs.position < rhs.position
        } else {
            return lhs.id < rhs.id
        }
    }
    
    
}


public struct Definition {
    public let id: String
    public let location: LocationPair?
    public let strings: StringTable
    public let properties: [String:Any]
    public let names: [String]
    public let exits: [String:String]
    public let traits: [String]
    public let dialogue: Dialogue?
    public let mass: Double
    public let volume: Double
    public let handlers: Handlers
    
    init(id: String, properties: [String:Any]) {
        self.id = id
        self.properties = properties

        self.dialogue = Dialogue(from: properties["dialogue"] as? [String:Any])
        self.handlers = Handlers(from: properties["handlers"], dialogue: dialogue)
        self.location = LocationPair(from: properties["location"])
        self.strings = StringTable(from: properties["strings"])
        self.names = (properties["names"] as? [String]) ?? []
        self.exits = (properties["exits"] as? [String:String]) ?? [:]
        self.mass = properties[asDouble: "mass"] ?? 0
        self.volume = properties[asDouble: "volume"] ?? 0
        
        var traits: [String] = (properties["traits"] as? [String]) ?? []
        if let kind = properties[asString: "type"] {
            traits.append(kind)
        }
        self.traits = traits
        
        if dialogue != nil {
            dialogueChannel.log("Object \(id) has dialogue.")
        }
    }
    
    func hasFlag(_ key: String) -> Bool {
        guard let value = properties[key] as? Bool else { return false }
        return value
    }
}

