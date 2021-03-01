// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

enum EventId: String {
    case contentAdded
    case contentRemoved
    case movedFrom
    case movedTo
    
}

struct Event {
    let id: String
    let target: Object
    let parameters: [String:Any]
    let propogates: Bool

    init(id: EventId, target: Object, propogates: Bool = false, parameters: [String:Any]) {
        self.init(id: id.rawValue, target: target, propogates: propogates, parameters: parameters)
    }
    
    init(id: String, target: Object, propogates: Bool = false, parameters: [String : Any] = [:]) {
        self.id = id
        self.target = target
        self.propogates = propogates
        self.parameters = parameters
    }
}

extension Event: CustomStringConvertible {
    var description: String {
        let params = parameters.count > 0 ? " params: \(parameters)" : ""
        return "«event \(id) target: \(target)\(params)»"
    }
}
