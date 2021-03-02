// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct PersonBehaviour: Behaviour {
    static var id: String { "person" }

    let object: Object

    init(_ object: Object, data: Any) {
        self.object = object
    }
    
    static func data(for object: Object) -> Any {
        return ()
    }
}
