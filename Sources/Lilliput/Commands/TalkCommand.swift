// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class TalkCommand: TargetedCommand {
    init() {
        super.init(keywords: ["talk to", "talk"])
    }
    
    override func perform(in context: CommandContext) {
        context.player.joinConversation(with: [context.target])
    }
}
