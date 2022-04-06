// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let takenFlag = "taken"
}

class TakeCommand: NonExclusiveTargetedCommand {
    init() {
        super.init(keywords: ["take", "get"])
    }
    
    override func kind(in context: CommandContext) -> Command.Match.Kind {
        if context.target.isCarriedByPlayer {
            // only apply command to things we've already got as a fallback, if nothing else matches
            return .fallback
        } else {
            return super.kind(in: context)
        }
    }
    
    override func matchesAll(in context: CommandContext) -> Bool {
        let object = context.target
        return (object.location != context.player) && object.hasFlag(.awareFlag)
    }

    override func perform(in context: CommandContext) {
        let object = context.target
        let brief = object.getDefinite()
        let output: String
        
        if object.isCarriedByPlayer {
            output = "You already have \(brief)."
        } else if object.contains(context.player) {
            output = "You can't pick up something that contains you!"
        } else if !object.hasFlag(.awareFlag) {
            output = "You can't see \(brief) here."
        } else if let description = object.getText(for: .preventTake) {
            output = description
        } else {
            let player = context.player
            
            if object.definition.mass > player.maximumMass {
                output = object.getText(for: .tooHeavy) ?? "\(brief.capitalizedFirst) is too heavy."
            } else if object.definition.volume > player.maximumVolume {
                output = object.getText(for: .tooLarge) ?? "\(brief.capitalizedFirst) is too large."
            } else if player.containedMass + object.definition.mass > player.maximumMass {
                output = object.getText(for: .excessMass) ?? "You are carrying too much."
            } else if player.containedVolume + object.definition.volume > player.maximumVolume {
                output = object.getText(for: .excessVolume) ?? "You don't have room for that."
            } else {
                object.move(to: context.player)
                object.setFlag(.takenFlag)
                output = "You take \(brief)."
                context.engine.post(event: Event(.taken, target: context.target))
            }
        }
        
        context.engine.output(output)
    }
}

class TakeFallbackCommand: TakeCommand {
    override func kind(in context: CommandContext) -> Command.Match.Kind {
        return .fallback
    }
    
    override func matches(_ context: CommandContext) -> Bool {
        guard keywordMatches(in: context), arguments.count > 0 else { return false }
        let target = arguments.joined(separator: " ")
        return target == "all"
    }

    override func perform(in context: CommandContext) {
        context.engine.output("There is nothing here that you can take.")
    }
}

