// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class GoCommand: Command {
    init() {
        super.init(keywords: ["go", "g"])
    }
    
    override func matches(_ context: Context) -> Bool {
        let input = context.input
        let direction = super.matches(context) ? input.arguments[0] : input.command
        
        
        if let location = context.player.location, let trait = location.trait(LocationTrait.self) {
            let exits = trait.allExits
        }
        
        return false
    }
    
    override func perform(in context: Context) {
    }
}
