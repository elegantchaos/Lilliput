// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct PortalBehaviour: Behaviour {
    static var id: String { "portal" }
    
    fileprivate struct Data {
        let links: [String]
        
        init(for object: Object) {
            self.links = (object.getProperty(withKey: "links") as? [String]) ?? []
        }
    }
    
    let object: Object
    fileprivate let data: Data

    init(_ object: Object, storage: Any) {
        self.object = object
        self.data = storage as! Data
    }

    static func storage(for object: Object) -> Any {
        return Data(for: object)
    }
    
    func didSetup() {
        let engine = object.engine
        for link in data.links {
            if let location = LocationBehaviour(engine.objects[link]) {
                location.link(portal: object, to: data.links)
            }
        }
    }
    
    var impassableDescription: String {
        if let description = object.getText(for: .locked) {
            return description
        }
        
        return "\(object.getDefinite().capitalizedFirst) is locked."
    }
}
