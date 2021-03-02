// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct WearableBehaviour: Behaviour {
    static var id: String { "wearable" }
    
    static var commands: [Command] {
        [
            RemoveCommand(),
            WearCommand(),
        ]
    }
    
    let object: Object
    
    init(_ object: Object, storage: Any) {
        self.object = object
    }
    
}
