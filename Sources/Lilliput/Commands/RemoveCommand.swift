// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class RemoveCommand: TargetedCommand {
    init() {
        super.init(keywords: ["remove", "take off"])
    }
    
    override func perform(in context: CommandContext) {
        let object = context.target
        let brief = object.getDefinite()

        let output: String
        if !object.isCarriedByPlayer || object.position != .worn {
            output = "You are not wearing \(brief)."
        } else {
            object.move(to: context.player, position: .in)
            output = "You remove \(brief)."
        }
        
        context.engine.output(output)
    }
}
