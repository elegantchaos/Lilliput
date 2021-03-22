// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let takenFlag = "taken"
}

class TakeCommand: TargetedCommand {
    init() {
        super.init(keywords: ["take", "get"])
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
        } else {
            let player = context.player
            
            if object.definition.mass > player.maximumMass {
                output = object.getDescription(for: .tooHeavy) ?? "\(brief.capitalizedFirst) is too heavy."
            } else if object.definition.volume > player.maximumVolume {
                output = object.getDescription(for: .tooLarge) ?? "\(brief.capitalizedFirst) is too large."
            } else if player.containedMass + object.definition.mass > player.maximumMass {
                output = object.getDescription(for: .excessMass) ?? "You are carrying too much."
            } else if player.containedVolume + object.definition.volume > player.maximumVolume {
                output = object.getDescription(for: .excessVolume) ?? "You don't have room for that."
            } else {
                object.move(to: context.player)
                object.setFlag(.takenFlag)
                output = "You take \(brief)."
            }
        }
        
        context.engine.output(output)
    }
}
