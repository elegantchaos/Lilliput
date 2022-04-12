// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CollectionExtensions

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
