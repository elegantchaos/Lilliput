// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class DropCommand: NonExclusiveTargetedCommand {
    init() {
        super.init(/*keywords: ["drop", "put"], */patterns: [#"^(?: drop|put)\s+(.*?)\s+(in|on|into|onto)\s+(.*?)$"#])
    }
    
    override func keywordMatches(in context: CommandContext) -> Bool {
        return super.keywordMatches(in: context)
    }
    
    override func matchesAll(in context: CommandContext) -> Bool {
        return context.target.location == context.player
    }
    
    override func kind(in context: CommandContext) -> Command.Match.Kind {
        if !context.target.isCarriedByPlayer {
            // only apply command to things we don't have as a fallback, if nothing else matches
            return .fallback
        } else {
            return super.kind(in: context)
        }
    }
    

    override func perform(in context: CommandContext) {
        var location = context.player.location
        var position: Position = .in

        if (arguments.count == 3) {
            let destinationName = arguments[2]
            for candidate in context.candidates {
                if candidate.names.contains(destinationName), let object = candidate.owningObject {
                    location = object
                    if let pos = Position(preposition: arguments[1]) {
                        position = pos
                    }
                    break
                }
            }
        }
        
        if let location = location {
            let object = context.target
            let brief = object.getDefinite()
            if object.isCarriedByPlayer {
                object.setFlag(.awareFlag)
                object.move(to: location, position: position)
                switch position {
                case .in:
                    let description =
                        object.getDescription(for: "drop.\(location.id)") ??
                        object.getDescription(for: "drop") ??
                        "You drop \(brief)."
                    context.engine.output(description)
                    
                default:
                    context.engine.output("You put \(brief) \(position) \(location.getDefinite()).")
                }
            } else {
                context.engine.output("You do not have \(brief).")
            }
        }
    }
}
