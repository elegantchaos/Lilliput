// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/08/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct FillableBehaviour: Behaviour {
    static var id: String { "fillable" }
    static var commands: [Command] {
        [
            FillCommand()
        ]
    }

    let object: Object
    init(_ object: Object, storage: Any) {
        self.object = object
    }
}
