// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class LeaveCommand: TargetedCommand {
    init() {
        super.init(keywords: ["leave"])
    }
    
    override func perform(in context: CommandContext) {
        let location = context.target
        let brief = location.getDefinite()
        let player = context.player
        let output: String
        
        if player.location == location {
            if let container = location.location {
                output = "You exit \(brief)."
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
