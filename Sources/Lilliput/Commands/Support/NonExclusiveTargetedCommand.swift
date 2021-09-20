// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/06/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class NonExclusiveTargetedCommand: TargetedCommand {
    var matchedAll = false
    
    override func matches(target: String, in context: CommandContext) -> Bool {
        if target == "all" {
            matchedAll = matchesAll(in: context)
            return matchedAll
        } else {
            return super.matches(target: target, in: context)
        }
    }
    
    func matchesAll(in context: CommandContext) -> Bool {
        return true
    }
    
    override func kind(in context: CommandContext) -> Match.Kind {
        return .normal
    }
}
