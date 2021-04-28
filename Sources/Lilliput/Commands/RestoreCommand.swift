// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class RestoreCommand: Command {
    init() {
        super.init(keywords: ["restore"])
    }

    override func perform(in context: CommandContext) {
        let name = arguments.first ?? "default"
        context.engine.restore(from: name)
    }
}
