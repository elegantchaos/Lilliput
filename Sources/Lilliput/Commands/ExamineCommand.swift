// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let examinedFlag = "examined"
}

class ExamineCommand: NonExclusiveTargetedCommand {
    init() {
        super.init(keywords: ["examine", "look at", "look in", "look out of", "look through", "look", "search", "l", "ex"])
    }
    
    override func perform(in context: CommandContext) {
        if !matchedAll || includedInExamineAll(context) {
            let object = context.target
            let description = object.getDescriptionAndContents()
            let prefix = context.hasMultipleTargets ? "\(object.getDefinite().sentenceCased): " : ""
            object.setFlag(.examinedFlag)
            object.setFlag(.awareFlag)
            context.engine.output("\(prefix)\(description)")
            context.engine.post(event: Event(.examined, target: context.target))
        }
    }
    
    func includedInExamineAll(_ context: CommandContext) -> Bool {
        let object = context.target
        if object == context.player { return false }
        if object.location == context.player { return false }
        guard let playerLocation = context.player.location else { return false }
        return object.isVisibleFrom(playerLocation)
    }
}

class ExamineFallbackCommand: ExamineCommand {
    override func matches(_ context: CommandContext) -> Bool {
        keywordMatches(in: context) && arguments.count == 0
    }
    
    override func kind(in context: CommandContext) -> Command.Match.Kind {
        return .fallback
    }
    
    override func perform(in context: CommandContext) {
        if let description = PlayerBehaviour(context.player)?.describeLocation() {
            context.engine.output(description)
        }
    }
}
