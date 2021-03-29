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

    override func perform(in context: CommandContext) {
        if let output = context.target.getDescription(for: useContext) {
            context.engine.output(output)
        }
        context.engine.post(event: Event(.used, target: context.target))
    }
}
