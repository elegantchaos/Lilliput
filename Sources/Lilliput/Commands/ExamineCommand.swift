// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class ExamineCommand: Command {
    let shouldMatchTarget: Bool
    
    init(shouldMatchTarget: Bool = true) {
        self.shouldMatchTarget = shouldMatchTarget
        super.init(keywords: ["examine", "look", "search", "l", "ex"])
    }
    
    override func matches(_ context: Context) -> Bool {
        if shouldMatchTarget && inputMatchesTarget(in: context) {
            return true
        }
        
        return (!shouldMatchTarget && context.input.arguments.count == 0)
    }
    
    override func perform(in context: Context) {
        if shouldMatchTarget {
            let object = context.target
            object.showDescriptionAndContents()
            object.setFlag("examined")
        } else {
            context.player.showLocation()
        }
    }
}
