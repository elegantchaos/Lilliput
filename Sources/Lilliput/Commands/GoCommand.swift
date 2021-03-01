// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class GoCommand: Command {
    var matchedExit: Exit?
    
    init() {
        super.init(keywords: ["go", "g"])
    }
    
    override func matches(_ context: Context) -> Bool {
        let input = context.input
        let direction = super.matches(context) ? input.arguments[0] : input.command
        
        if let location = context.player.location {
            for exit in location.allExits {
                if (exit.key == direction) || exit.key.starts(with: direction) {
                    matchedExit = exit.value
                    return true
                }
            }
        }
        
        return false
    }
    
    override func perform(in context: Context) {
        if let exit = matchedExit {
            matchedExit = nil
            if exit.isPassable {
                context.player.move(to: exit.destination)
            } else if let portal = exit.portal, let aspect = portal.aspect(PortalTrait.self) {
                context.engine.output(aspect.getImpassableDescription(for: portal))
            } else {
                context.engine.output("You can't go that way!")
            }
        }
    }
}
