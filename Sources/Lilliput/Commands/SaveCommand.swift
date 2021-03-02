// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class SaveCommand: Command {
    init() {
        super.init(keywords: ["save"])
    }
    
    override func perform(in context: CommandContext) {
        let name = context.input.arguments.first ?? "default"
        context.engine.save(to: name)
    }
}
