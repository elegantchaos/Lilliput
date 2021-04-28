// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class StandCommand: Command {
    init() {
        super.init(keywords: ["get up", "stand up", "stand"])
    }
    
    override func perform(in context: CommandContext) {
        let player = context.player
        if player.hasFlag(.sittingFlag), let location = player.location?.location {
            player.clearFlag(.sittingFlag)
            player.move(to: location, position: .in)
            context.engine.output("You stand up.")
        } else {
            context.engine.output("You are already standing.")
        }
    }
}
