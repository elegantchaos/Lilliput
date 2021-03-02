// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Command {
    let keywords: [String]
    
    init(keywords: [String] = []) {
        self.keywords = keywords
    }
    
    func keywordMatches(context: CommandContext) -> Bool {
        return keywords.contains(context.input.command)
    }

    func matches(_ context: CommandContext) -> Bool {
        return keywordMatches(context: context)
    }
    
    func perform(in context: CommandContext) {
        
    }
}
