// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let carriedFlag = "carried"
    static let takenFlag = "taken"
}

class TakeCommand: TargetedCommand {
    init() {
        super.init(keywords: ["take", "get"])
    }
    
    override func perform(in context: CommandContext) {
        let object = context.target
        let brief = object.getDefinite()
        let output: String
        
        if object.isCarriedByPlayer {
            output = "You already have \(brief)."
        } else if object.contains(context.player) {
            output = "You can't pick up something that contains you!"
        } else if !object.hasFlag(.examinedFlag) {
            output = "You can't see \(brief) here."
        } else {
            object.move(to: context.player)
            object.setFlag(.carriedFlag)
            object.setFlag(.takenFlag)
            output = "You take \(brief)."
        }
        
        context.engine.output(output)
    }
}
