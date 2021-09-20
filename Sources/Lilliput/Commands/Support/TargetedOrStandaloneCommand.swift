// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 20/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class TargetedOrStandaloneCommand: TargetedCommand {
    override func matches(_ context: CommandContext) -> Bool {
        super.matches(context) || (keywords.contains(context.input.command) && (arguments.count == 0))
    }
}
