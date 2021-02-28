// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Context {
    let input: Input
    let target: CommandOwner
    let engine: Engine
    let player: Object
    let location: Object
    
    init(input: Input, target: CommandOwner, engine: Engine) {
        self.input = input
        self.target = target
        self.engine = engine
        self.player = engine.player
        self.location = player.location!
    }
}
