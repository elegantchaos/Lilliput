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
    
    var asInterchange: Any {
        switch position {
            case .in:
                return id
            default:
                let result: [String:Any] = [.locationKey: id, .positionKey: position.rawValue]
                return result
        }
    }
}

public struct StringTable {
    public typealias Index = [String:StringAlternatives]
    public let table: Index
    
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
    
    public var asInterchange: [String: Any] {
        return table.mapValues({ $0.asInterchange })
    }
}

public struct StringAlternatives {
    public let strings: [String]
    
    init?(_ data: Any?) {
        if let string = data as? String {
            self.strings = [string]
        } else if let strings = data as? [String] {
            self.strings = strings
        } else {
            return nil
        }
    }
    
    var asInterchange: Any {
        if strings.count == 1 {
            return strings[0]
        } else {
            return strings
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
    
    var asInterchange: [String:Any] {
        var properties: [String:Any] = [:]
        
        properties[nonEmpty: "dialogue"] = dialogue?.asInterchange
        properties[nonEmpty: "handlers"] = handlers.asInterchange
        properties["location"] = location?.asInterchange
        properties[nonEmpty: "strings"] = strings.asInterchange
        properties[nonEmpty: "names"] = names
        properties[nonEmpty: "exits"] = exits
        properties[nonZero: "mass"] = mass
        properties[nonZero: "volume"] = volume
        properties[nonEmpty: "traits"] = traits

        return properties
    }
}

extension Dictionary where Value == Any {
    subscript<V: Equatable>(_ key: Key, skipIf skip: V) -> V? {
        get {
            return self[key] as? V
        }
        set(newValue) {
            if newValue == skip {
                removeValue(forKey: key)
            } else {
                self[key] = newValue
            }
        }
    }

    subscript<V: BinaryFloatingPoint>(nonZero key: Key) -> V? {
        get {
            fatalError("write-only")
        }
        set(newValue) {
            if newValue == 0.0 {
                removeValue(forKey: key)
            } else {
                self[key] = newValue
            }
        }
    }

    subscript<V: Collection>(nonEmpty key: Key) -> V? {
        get {
            fatalError("write-only")
        }
        set(newValue) {
            if newValue?.isEmpty ?? false {
                removeValue(forKey: key)
            } else {
                self[key] = newValue
            }
        }
    }

}
