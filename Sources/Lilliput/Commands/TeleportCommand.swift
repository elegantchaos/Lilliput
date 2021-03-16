// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class TeleportCommand: Command {
    var matchedLocation: Object?
    
    init() {
        super.init(keywords: ["teleport"])
    }
    
    override func matches(_ context: CommandContext) -> Bool {
        guard super.matches(context) else { return false }
        

        if
            let object = context.engine.objects[context.input.arguments[0]], let _ = LocationBehaviour(object) {
                matchedLocation = object
                return true
        }
        
        return false
    }
    
    override func perform(in context: CommandContext) {
        if let location = matchedLocation {
            context.engine.output("(debug: user has been teleported to \(location.id))")
            context.player.move(to: location)
        } else {
            context.engine.output("Unknown location!")
        }
    }
}
