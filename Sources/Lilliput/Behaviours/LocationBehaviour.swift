// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct LocationBehaviour: Behaviour {
    static var id: String { "location" }

    struct Storage {
        fileprivate let exits: Exits
        init(for object: Object) {
            self.exits = Exits(for: object)
        }
    }
    
    let object: Object
    let storage: Storage

    init(_ object: Object, storage: Any) {
        self.object = object
        self.storage = storage as! Storage
    }

    static func storage(for object: Object) -> Any {
        return Storage(for: object)
    }
    
    var inputCandidates: [CommandOwner] {
        var candidates: [CommandOwner] = []

        candidates.append(contentsOf: object.contents.allObjects)
        candidates.append(contentsOf: portals)
        candidates.append(object)
        
        return candidates
    }
    
    var allExits: [String:Exit] {
        var exits: [String:Exit] = [:]
        var location: LocationBehaviour? = self
        while let behaviour = location {
            exits.merge(behaviour.storage.exits.exits, uniquingKeysWith: { existing, new in existing })
            location = LocationBehaviour(behaviour.object.location)
        }
        
        return exits
    }
    
    var portals: [Object] {
        let portals = storage.exits.exits.values.compactMap({ $0.portal })
        return portals
    }

    func describeExits() -> String {
        return storage.exits.describe(for: object)
    }
    
    func link(portal object: Object, to destinations: [String]) {
        storage.exits.link(portal: object, to: destinations)
    }
 
}

extension LocationBehaviour.Storage: CustomStringConvertible {
    var description: String {
        "exits: \(exits)"
    }
}
