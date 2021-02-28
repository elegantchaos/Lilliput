// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class Command {
    let keywords: [String]
    
    init(keywords: [String] = []) {
        self.keywords = keywords
    }
    
    func matches(_ context: Context) -> Bool {
        return keywords.contains(context.input.command)
    }
    
    func inputMatchesTarget(in context: Context) -> Bool {
        guard context.input.arguments.count > 0 else { return false }
        
        var target = context.input.arguments.joined(separator: " ")
        if target == "self" {
            target = "player"
        }
        
        return context.target.names.contains(target)
    }
    
    func perform(in context: Context) {
        
    }
}
