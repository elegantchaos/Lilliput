// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct LocationBehaviour: Behaviour {
    init(_ object: Object, data: Any) {
        self.object = object
        self.data = data as! Data
    }
    
    static var id: String { "location" }

    struct Data {
        fileprivate let exits: Exits
    }
    
    let object: Object
    let data: Data

    static func data(for object: Object) -> Any {
        return Data(exits: Exits(for: object))
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
            exits.merge(behaviour.data.exits.exits, uniquingKeysWith: { existing, new in existing })
            location = LocationBehaviour(behaviour.object.location)
        }
        
        return exits
    }
    
    func getExitDescription(exit: Exit, direction: String) -> String {
        var description = direction
        
        if let portal = exit.portal {
            let brief = portal.getDescriptionWarnIfMissing(for: .exit)
            description += " \(brief)"
        }
        
        if object.engine.player.hasVisited(location: exit.destination) {
            let brief = exit.destination.getDefinite()
            description += " to \(brief)"
        }

        return description
    }


    var portals: [Object] {
        let portals = data.exits.exits.values.compactMap({ $0.portal })
        return portals
    }

    func showExits() {
        data.exits.show(for: object)
    }
    
    func link(portal object: Object, to destinations: [String]) {
        data.exits.link(portal: object, to: destinations)
    }
 
}
