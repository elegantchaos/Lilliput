// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct SittableBehaviour: Behaviour {
    static var id: String { "sittable" }
    static var commands: [Command] {
        [
            LeaveCommand(),
            SitCommand(),
        ]
    }
    let object: Object
    
    init(_ object: Object, storage: Any) {
        self.object = object
    }
}
