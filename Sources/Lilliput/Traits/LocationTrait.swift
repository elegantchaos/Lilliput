// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct LocationTrait: Trait {
    static var id: String { "location" }

    let exits: Exits
    
    init(with object: Object) {
        self.exits = Exits(for: object)
    }
}

extension Object {
    func getExitDescription(exit: Exit, direction: String) -> String {
        var description = direction
        
        if let portal = exit.portal {
            let brief = portal.getDescriptionWarnIfMissing(for: .exit)
            description += " \(brief)"
        }
        
        if engine.player.hasVisited(location: exit.destination) {
            let brief = exit.destination.getDefinite()
            description += " to \(brief)"
        }

        return description
    }

    var allExits: [String:Exit] {
        var exits: [String:Exit] = [:]
        var location: Object? = self
        while let traits = location?.trait(LocationTrait.self) {
            exits.merge(traits.exits.exits, uniquingKeysWith: { existing, new in existing })
            location = location?.location
        }
        return exits
    }

}
