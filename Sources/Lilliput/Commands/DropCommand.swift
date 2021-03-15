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
                object.setFlag(.awareFlag)
                object.move(to: location)
                let description =
                    object.getDescription(for: "drop.\(location.id)") ??
                    object.getDescription(for: "drop") ??
                    "You drop \(brief)."
                context.engine.output(description)
            } else {
                context.engine.output("You do not have \(brief).")
            }
        }
    }
}
