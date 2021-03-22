// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Exit {
    let destination: Object
    var portal: Object?
    
    init(to destination: Object, portal: Object? = nil) {
        self.destination = destination
        self.portal = portal
    }
    
    var isPassable: Bool {
        guard let portal = portal else { return true }
        return !portal.hasFlag("locked")
    }
    
    var isVisible: Bool {
        guard let portal = portal else { return true }
        return !portal.hasFlag("hidden")
    }
}
