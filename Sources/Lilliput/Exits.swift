// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

let exitsChannel = Channel("Exits")
class Exits {
    var exits: [String:Exit]
    
    init(for object: Object) {
        let engine = object.engine
        var exits: [String:Exit] = [:]
        for exit in object.definition.exits {
            if let destination = engine.objects[exit.value] {
                exits[exit.key] = Exit(to: destination)
            } else {
                engine.warning("Missing exit \(exit.value) for \(object).")
            }
        }
        
        self.exits = exits
    }

    func getExitDescription(exit: Exit, direction: String, player: Object) -> String {
        var description = direction
        
        if let portal = exit.portal {
            let brief = portal.getDescriptionWarnIfMissing(for: .exit)
            description += " \(brief)"
        }
        
        let destination = exit.destination
        if player.hasVisited(location: destination) || destination.hasFlag("knownWithoutVisiting"){
            let brief = destination.getDefinite()
            description += " to \(brief)"
        }

        return description
    }

    func describe(for object: Object) -> String {
        var output = ""
        let player = object.engine.player!
        let count = exits.count
        if count > 0 {
            let start = count == 1 ? "There is a single exit " : "There are exits "
            
            var body: [String] = []
            for exit in exits {
                let string = getExitDescription(exit: exit.value, direction: exit.key, player: player)
                body.append(string)
            }
            
            let list = body.joined(separator: ", ")
            output += "\(start)\(list)."
        }
        
        return output
    }
    
    func link(portal: Object, to destinations: [String]) {
        for exit in exits {
            let destination = exit.value.destination
            if destinations.contains(destination.id) {
                exitsChannel.debug("Linked \(portal) as portal to \(destination)")
                var updated = exit.value
                updated.portal = portal
                exits[exit.key] = updated
            }
        }

    }
}
