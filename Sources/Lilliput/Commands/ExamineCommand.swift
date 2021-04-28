// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let examinedFlag = "examined"
}

class ExamineCommand: TargetedCommand {
    let shouldMatchTarget: Bool
    
    init(shouldMatchTarget: Bool = true) {
        self.shouldMatchTarget = shouldMatchTarget
        super.init(keywords: ["examine", "look at", "look in", "look out of", "look through", "look", "search", "l", "ex"])
    }
    
    override func matches(_ context: CommandContext) -> Bool {
        if shouldMatchTarget && super.matches(context) {
            return true
        }
        
        return (!shouldMatchTarget && keywordMatches(context: context) && context.input.arguments.count == 0)
    }
    
    override func perform(in context: CommandContext) {
        if shouldMatchTarget {
            let object = context.target
            let description = object.getDescriptionAndContents()
            object.setFlag(.examinedFlag)
            object.setFlag(.awareFlag)
            context.engine.output(description)
        } else if let description = PlayerBehaviour(context.player)?.describeLocation() {
            context.engine.output(description)
        }
    }
}
