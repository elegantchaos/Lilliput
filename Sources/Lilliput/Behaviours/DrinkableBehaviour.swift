// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/08/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct DrinkableBehaviour: Behaviour {
    static var id: String { "drinkable" }
    static var commands: [Command] {
        [
            DrinkCommand(),
        ]
    }

    let object: Object
    init(_ object: Object, storage: Any) {
        self.object = object
    }
}
