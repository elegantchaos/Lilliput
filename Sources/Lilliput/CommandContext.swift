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
    let candidates: [CommandOwner]
    let matches: [Command.Match]?
    
    var player: Object {
        playerBehviour.object
    }
    
    var playerStats: PlayerBehaviour.PlayerStats {
        playerBehviour.stats
    }
    
    init(input: Input, target: CommandOwner, engine: Engine, candidates: [CommandOwner]) {
        self.input = input
        self.owner = target
        self.engine = engine
        self.playerBehviour = PlayerBehaviour(engine.player)!
        self.location = playerBehviour.object.location!
        self.candidates = candidates
        self.matches = nil
    }
    
    init(match: Command.Match, from matches: [Command.Match], candidates: [CommandOwner]) {
        self.input = match.context.input
        self.owner = match.context.owner
        self.engine = match.context.engine
        self.playerBehviour = match.context.playerBehviour
        self.location = match.context.location
        self.candidates = candidates
        self.matches = matches
    }
    
    var target: Object {
        owner as! Object
    }
    
    var hasMultipleTargets: Bool {
        matches.map { $0.count > 1 } ?? false
    }
}
