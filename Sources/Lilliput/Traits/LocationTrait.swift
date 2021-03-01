// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct LocationTrait: Trait {
    let exits: [String:Exit]
    
    init(with object: Object) {
        self.exits = object.setupExits()
    }
    
    static var id: String { "location" }
    
    


    func showExits(for object: Object) {
        let count = exits.count
        if count > 0 {
            let start = count == 1 ? "There is a single exit " : "There are exits "
            
            var body: [String] = []
            for exit in exits {
                let string = object.getExitDescription(exit: exit.value, direction: exit.key)
                body.append(string)
            }
            
            let list = body.joined(separator: ", ")
            object.engine.output("\(start)\(list).")
        }
    }
}

extension Object {
    func setupExits() -> [String:Exit] {
        var exits: [String:Exit] = [:]
        for exit in definition.exits {
            if let destination = engine.objects[exit.value] {
                exits[exit.key] = Exit(to: destination)
            } else {
                engine.warning("Missing exit \(exit.value) for \(self).")
            }
        }
        return exits
    }

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
            exits.merge(traits.exits, uniquingKeysWith: { existing, new in existing })
            location = location?.location
        }
        return exits
    }

}
