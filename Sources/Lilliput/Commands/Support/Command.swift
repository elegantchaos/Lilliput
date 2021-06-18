// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Command {
    struct Match: Comparable {
        let command: Command
        let context: CommandContext
        let exclusive: Bool
        let priority: Double

        init(command: Command, context: CommandContext) {
            self.command = command
            self.context = context
            self.exclusive = command.exclusive(in: context)
            self.priority = command.priority(in: context)
        }
        
        static func < (lhs: Command.Match, rhs: Command.Match) -> Bool {
            if lhs.exclusive == rhs.exclusive {
                return lhs.priority < rhs.priority
            } else {
                return rhs.exclusive
            }
        }
        
        static func == (lhs: Command.Match, rhs: Command.Match) -> Bool {
            lhs.command.keywords == rhs.command.keywords
        }
    }

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

    func exclusive(in context: CommandContext) -> Bool {
        return true
    }
    
    func priority(in context: CommandContext) -> Double {
        return 1.0
    }
    
    func matches(_ context: CommandContext) -> Bool {
        return keywordMatches(context: context)
    }
    
    func perform(in context: CommandContext) {
        
    }
}
