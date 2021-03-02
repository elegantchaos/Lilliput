// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct CommandContext {
    let input: Input
    let owner: CommandOwner
    let engine: Engine
    let player: Object
    let location: Object
    
    init(input: Input, target: CommandOwner, engine: Engine) {
        self.input = input
        self.owner = target
        self.engine = engine
        self.player = engine.player
        self.location = player.location!
    }
    
    var target: Object {
        owner as! Object
    }
}
