// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Command {
    let keywords: [String]
    var arguments: [String] = []
    
    init(keywords: [String] = []) {
        self.keywords = keywords
    }
    
    func keywordMatches(context: CommandContext) -> Bool {
        for keyword in keywords {
            let raw = context.input.raw
            if raw.starts(with: keyword) {
                let index = raw.index(raw.startIndex, offsetBy: keyword.count)
                
                let remainder = raw[index...]
                self.arguments = remainder.split(separator: " ").map(as: String.self)
                return true
            }
        }
        
        return false
    }

    func matches(_ context: CommandContext) -> Bool {
        return keywordMatches(context: context)
    }
    
    func perform(in context: CommandContext) {
        
    }
}
