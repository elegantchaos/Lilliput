// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let sittingFlag = "sitting"
}

class SitCommand: TargetedOrStandaloneCommand {
    init() {
        super.init(keywords: ["sit on", "sit down", "sit"])
    }
    
    override func perform(in context: CommandContext) {
        let object = context.target
        let output: String
        
        if let obstacle = object.contents.anyObject {
            let brief = obstacle.getDefinite()
            output = "You need to remove \(brief) first."
            
        } else if object.isCarriedByPlayer {
            let brief = object.getDefinite()
            output = "You need to put down \(brief) first."
            
        } else {
            let position = Position(rawValue: object.getString(withKey: "sitMode")) ?? .on
            let player = context.player
            
            player.setFlag(.sittingFlag)
            player.move(to: object, position: position)
            context.engine.post(event: Event(.sat, target: player, propogates: true, parameters: ["on": object]))
            let brief = object.getDefinite()
            output = "You sit \(position) \(brief)."
        }
        
        context.engine.output(output)
    }
}
