// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class UseCommand: TargetedCommand {
    let useContext: DescriptionContext
    
    init(context: DescriptionContext = .use, keywords: [String] = ["use"]) {
        self.useContext = context
        super.init(keywords: keywords)
    }
 
    override func matches(_ context: CommandContext) -> Bool {
        guard super.matches(context) else { return false }
        return context.target.getDescription(for: useContext) != nil
    }
    
    override func perform(in context: CommandContext) {
        if let output = context.target.getDescription(for: useContext) {
            context.engine.output(output)
        }
    }
}
