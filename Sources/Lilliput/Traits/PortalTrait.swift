// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct PortalTrait: Trait {
    static var id: String { "portal" }

    init(with object: Object) {
    }
    
    func getImpassableDescription(for object: Object) -> String {
        if let description = object.getDescription(for: .locked) {
            return description
        }
        
        return "\(object.getDefinite()) is locked."
    }
}
