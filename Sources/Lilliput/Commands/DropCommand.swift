// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class DropCommand: TargetedCommand {
    init() {
        super.init(keywords: ["drop", "put"])
    }
    
    override func perform(in context: CommandContext) {
        if let location = context.player.location {
            let object = context.target
            let brief = object.getDefinite()
            if object.isCarriedByPlayer {
                object.move(to: location)
                object.clearFlag(.carriedFlag)
                context.engine.output("You drop \(brief).")
            } else {
                context.engine.output("You do not have \(brief).")
            }
        }
    }
}
