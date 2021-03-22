// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct UsableBehaviour: Behaviour {
    static var id: String { "usable" }
    static var commands: [Command] {
        [
            UseCommand(),
        ]
    }

    let object: Object
    init(_ object: Object, storage: Any) {
        self.object = object
    }
}
