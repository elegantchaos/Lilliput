// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/06/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class NonExclusiveTargetedCommand: TargetedCommand {
    override func matches(target: String, in context: CommandContext) -> Bool {
        return target == "all" ? matchesAll(in: context) : super.matches(target: target, in: context)
    }
    
    func matchesAll(in context: CommandContext) -> Bool {
        return true
    }
    
    override func exclusive(in context: CommandContext) -> Bool {
        return false
    }
}
