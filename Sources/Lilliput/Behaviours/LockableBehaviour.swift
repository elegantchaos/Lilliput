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

    struct Data {
        let requiredObject: Object?
        
        init(for object: Object) {
            requiredObject = object.getObject(withKey: "requires")
        }
    }

    let object: Object
    fileprivate let data: Data
    
    init(_ object: Object, data: Any) {
        self.object = object
        self.data = data as! Data
    }

    static func data(for object: Object) -> Any {
        return Data(for: object)
    }
    
    var playerHasReqirements: Bool {
        return data.requiredObject?.isCarriedByPlayer ?? true
    }
    
    var required: Object? {
        data.requiredObject
    }
}
