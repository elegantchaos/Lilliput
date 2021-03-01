// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

public let portalChannel = Channel("Portal")

struct PortalTrait: Trait {
    static var id: String { "portal" }

    let links: [String]
    
    init(with object: Object) {
        self.links = (object.getProperty(withKey: "links") as? [String]) ?? []
    }
    
    func didSetup(_ object: Object) {
        let engine = object.engine
        for link in links {
            if let location = engine.objects[link], let trait = location.trait(LocationTrait.self) {
                portalChannel.debug("Linked \(object) as portal to \(location)")
                trait.exits.link(object: object, asPortal: self)
            }
        }
        
    }
    
    func getImpassableDescription(for object: Object) -> String {
        if let description = object.getDescription(for: .locked) {
            return description
        }
        
        return "\(object.getDefinite()) is locked."
    }
}
