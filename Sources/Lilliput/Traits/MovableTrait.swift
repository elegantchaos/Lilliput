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
            TakeCommand()
        ]
    }

    let object: Object
    let data: ()
    
    init(_ object: Object, data: Any) {
        self.object = object
        self.data = data as! ()
    }
    
    static func data(for object: Object) -> Any {
        return ()
    }
}
