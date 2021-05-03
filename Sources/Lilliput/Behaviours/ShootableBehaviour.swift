// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct ShootableBehaviour: Behaviour {
    static var id: String { "shootable" }
    static var commands: [Command] {
        [
            ShootCommand(),
        ]
    }

    let object: Object
    init(_ object: Object, storage: Any) {
        self.object = object
    }
}
