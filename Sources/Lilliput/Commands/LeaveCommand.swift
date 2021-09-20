// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class LeaveCommand: TargetedCommand {
    init() {
        super.init(keywords: ["leave"])
    }

    override func kind(in context: CommandContext) -> Command.Match.Kind {
        return .exclusive
    }
    
    override func matches(_ context: CommandContext) -> Bool {
        if super.matches(context) {
            return true
        }
        
        return (keywords.contains(context.input.command) && (arguments.count == 0)) && (context.player.location == context.target)
    }
    
    override func perform(in context: CommandContext) {
        let location = context.target
        let brief = location.getDefinite()
        let player = context.player
        let output: String
        
        if player.location == location {
            if let container = location.location {
                output = location.getDescription(context: .leave)
                player.clearFlag(.sittingFlag)
                player.move(to: container)
            } else {
                output = "There's nowhere to go."
                // TODO: maybe pick an exit?
            }
        } else {
            output = "You are not in \(brief)."
        }
        
        context.engine.output(output)
    }
}

class LeaveFallbackCommand: Command {
    init() {
        super.init(keywords: ["leave"])
    }

    override func kind(in context: CommandContext) -> Command.Match.Kind {
        return .fallback
    }
    
    override func perform(in context: CommandContext) {
        let player = context.player
        if let location = player.location {
            let engine = context.engine
            let exits = location.definition.exits
            var output: String
            
            if let container = location.location {
                output = "You exit \(location.getDefinite())."
                player.clearFlag(.sittingFlag)
                player.move(to: container)
            } else if exits.count == 1, let exit = engine.objects[exits.first!.value] {
                output = "You leave \(location.getDefinite())."
                player.clearFlag(.sittingFlag)
                player.move(to: exit)
            } else {
                output = "Which way do you want to go?"
                if let exits = LocationBehaviour(player.location)?.describeExits(), !exits.isEmpty {
                    output += "\n\n\(exits)"
                }
            }
            
            context.engine.output(output)
        }
    }
}
