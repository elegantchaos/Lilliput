// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct MovableBehaviour: Behaviour {
    static var id: String { "movable" }
    static var commands: [Command] {
        [
            DropCommand(),
            TakeCommand(),
        ]
    }

    let object: Object
    let data: ()
    
    init(_ object: Object, storage: Any) {
        self.object = object
        self.data = storage as! ()
    }
    
    static func storage(for object: Object) -> Any {
        return ()
    }
}
