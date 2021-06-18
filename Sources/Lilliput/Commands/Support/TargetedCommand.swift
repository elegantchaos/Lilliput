// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class TargetedCommand: Command {
    func inputMatchesTarget(in context: CommandContext) -> Bool {
        guard arguments.count > 0 else { return false }
        
        var target = arguments.joined(separator: " ")
        if target == "self" {
            target = "player"
        }
        
        return matches(target: target, in: context)
    }
    
    func matches(target: String, in context: CommandContext) -> Bool {
        return context.target.names.contains(target)
    }
    
    override func matches(_ context: CommandContext) -> Bool {
        return super.matches(context) && inputMatchesTarget(in: context)
    }
}
