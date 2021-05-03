// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class GenerateEventCommand: TargetedCommand {
    let eventContext: DescriptionContext
    let eventID: EventID
    
    init(context: DescriptionContext = .use, eventID: EventID, keywords: [String] = ["use"]) {
        self.eventContext = context
        self.eventID = eventID
        super.init(keywords: keywords)
    }

    override func perform(in context: CommandContext) {
        if let output = context.target.getDescription(for: eventContext) {
            context.engine.output(output)
        }
        context.engine.post(event: Event(eventID, target: context.target))
    }
}
