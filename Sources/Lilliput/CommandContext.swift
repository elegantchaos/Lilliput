// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct CommandContext {
    let input: Input
    let owner: CommandOwner
    let engine: Engine
    let playerBehviour: PlayerBehaviour
    let location: Object
    
    var player: Object {
        playerBehviour.object
    }
    
    var playerStats: PlayerBehaviour.PlayerStats {
        playerBehviour.stats
    }
    
    init(input: Input, target: CommandOwner, engine: Engine) {
        self.input = input
        self.owner = target
        self.engine = engine
        self.playerBehviour = PlayerBehaviour(engine.player)!
        self.location = playerBehviour.object.location!
    }
    
    var target: Object {
        owner as! Object
    }
}
