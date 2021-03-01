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
    
    func keywordMatches(context: Context) -> Bool {
        return keywords.contains(context.input.command)
    }

    func matches(_ context: Context) -> Bool {
        return keywordMatches(context: context)
    }
    
    func perform(in context: Context) {
        
    }
}
