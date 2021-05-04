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
    
    override func matches(_ context: CommandContext) -> Bool {
        let input = context.input
        let explicitGo = super.matches(context)
        if explicitGo && arguments.count < 1 {
            return false // the user typed 'go' but gave no exit name
        }
        
        let requestedDirection = explicitGo ? arguments[0] : input.command
        
        if let location = LocationBehaviour(context.player.location) {
            for (direction, exit) in location.allExits {
                if exit.isVisible && ((direction == requestedDirection) || direction.starts(with: requestedDirection)) {
                    matchedExit = exit
                    return true
                }
            }
        }
        
        return false
    }
    
    override func perform(in context: CommandContext) {
        if let exit = matchedExit {
            matchedExit = nil
            if exit.isPassable {
                context.player.move(to: exit.destination)
            } else if let portal = PortalBehaviour(exit.portal) {
                context.engine.output(portal.impassableDescription)
            } else {
                context.engine.output("You can't go that way!")
            }
        }
    }
}

class GoFallbackCommand: Command {
    static let commonDirections = ["n", "ne", "e", "se", "s", "sw", "w", "nw", "up", "down", "in", "out"]
    init() {
        super.init(keywords: ["go", "g"])
    }

    override func matches(_ context: CommandContext) -> Bool {
        return super.matches(context) || Self.commonDirections.contains(context.input.command)
    }

    override func perform(in context: CommandContext) {
        if arguments.count == 0 {
            context.engine.output("Go where exactly?")
        } else {
            context.engine.output("There is no exit in that direction.")
        }
    }
}

