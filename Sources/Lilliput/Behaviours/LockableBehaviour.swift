// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation

struct LockableBehaviour: Behaviour {
    static var id: String { "lockable" }
    static var commands: [Command] {
        [
            LockCommand(),
            UnlockCommand()
        ]
    }

    struct Storage {
        let requiredObject: Object?
        
        init(for object: Object) {
            requiredObject = object.getObject(withKey: "requires")
        }
    }

    let object: Object
    fileprivate let storage: Storage
    
    init(_ object: Object, storage: Any) {
        self.object = object
        self.storage = storage as! Storage
    }

    static func storage(for object: Object) -> Any {
        return Storage(for: object)
    }
    
    var playerHasReqirements: Bool {
        return storage.requiredObject?.isCarriedByPlayer ?? true
    }
    
    var required: Object? {
        storage.requiredObject
    }
}
