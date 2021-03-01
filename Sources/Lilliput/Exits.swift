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

    func show(for object: Object) {
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
    
    func link(object: Object, asPortal portal: PortalTrait) {
        let links = portal.links
        for exit in exits {
            let destination = exit.value.destination
            if links.contains(destination.id) {
                exitsChannel.debug("Linked \(object) as portal to \(destination)")
                var updated = exit.value
                updated.portal = object
                exits[exit.key] = updated
            }
        }

    }
}
