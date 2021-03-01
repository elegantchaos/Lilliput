// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation

struct LockableTrait: Trait {
    static var id: String { "lockable" }
    
    let requiredObject: Object?
    
    static var commands: [Command] {
        [
            LockCommand(),
            UnlockCommand()
        ]
    }
    
    init(with object: Object) {
        requiredObject = object.getObject(withKey: "requires")
    }
}
