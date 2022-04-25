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

        var id: String {
            String(describing: type(of: self))
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
            lhs.command.patterns == rhs.command.patterns
        }
    }

    let keywords: [String]
    let patterns: [NSRegularExpression]
    
    var matched: String = ""
    var arguments: [String] = []
    
    init(keywords: [String] = [], patterns: [String] = []) {
        var expressions: [NSRegularExpression] = []
        
        for keyword in keywords {
//            if let expression = try? NSRegularExpression(pattern: "^\(keyword)$", options: .allowCommentsAndWhitespace) {
//                expressions.append(expression)
//            }
            if let expression = try? NSRegularExpression(pattern: "^\(keyword)(?: \\s+(.*))?+$", options: .allowCommentsAndWhitespace) {
                expressions.append(expression)
            }
        }
        
        expressions.append(contentsOf: patterns.compactMap({ try? NSRegularExpression(pattern: $0, options: .allowCommentsAndWhitespace) }))
        
        self.keywords = keywords
        self.patterns = expressions
    }
    
    func keywordMatches(in context: CommandContext) -> Bool {
        let raw = context.input.raw
        for pattern in patterns {
            if let match = pattern.matches(in: raw, options: .withoutAnchoringBounds, range: .init(location: 0, length: raw.count)).first {
                var captures: [String] = []
                let nsstring = raw as NSString
                for n in 1 ..< match.numberOfRanges {
                    let range = match.range(at: n)
                    if range.location != NSNotFound {
                        let capture = nsstring.substring(with: range)
                        captures.append(capture)
                    }
                }
                
                self.matched = pattern.pattern
                self.arguments = captures
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
