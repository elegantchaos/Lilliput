// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class Command {
    struct Match: Comparable {
        enum Kind: Comparable {
            case exclusive
            case normal
            case fallback
        }

        let command: Command
        let context: CommandContext
        let kind: Kind
        let priority: Double

        init(command: Command, context: CommandContext) {
            self.command = command
            self.context = context
            self.kind = command.kind(in: context)
            self.priority = command.priority(in: context)
        }
        
        static func < (lhs: Command.Match, rhs: Command.Match) -> Bool {
            if lhs.kind == rhs.kind {
                return lhs.priority < rhs.priority
            } else {
                return lhs.kind < rhs.kind
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
    
    func keywordMatches(in context: CommandContext) -> Bool {
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

    func kind(in context: CommandContext) -> Match.Kind {
        return .exclusive
    }
    
    func priority(in context: CommandContext) -> Double {
        return 1.0
    }
    
    func matches(_ context: CommandContext) -> Bool {
        return keywordMatches(in: context)
    }
    
    func perform(in context: CommandContext) {
        
    }
}
