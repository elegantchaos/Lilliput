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
    case replied
    
}

struct Event {
    let id: String
    let target: Object
    let propogates: Bool
    fileprivate let parameters: [String:Any]

    init(id: EventId, target: Object, propogates: Bool = false, parameters: [String:Any]) {
        self.init(id: id.rawValue, target: target, propogates: propogates, parameters: parameters)
    }
    
    init(id: String, target: Object, propogates: Bool = false, parameters: [String : Any] = [:]) {
        self.id = id
        self.target = target
        self.propogates = propogates
        self.parameters = parameters
    }
    
    subscript(stringWithKey key: String) -> String? {
        get {
            return parameters[asString: key]
        }
    }
    
    subscript(objectWithKey key: String) -> Object? {
        get {
            return parameters[key] as? Object
        }
    }
    
    var nonPropogating: Event {
        if !propogates {
            return self
        }
        
        return Event(id: id, target: target, propogates: false, parameters: parameters)
    }
}

extension Event: CustomStringConvertible {
    var description: String {
        if parameters.count == 0 {
            return "«event \(id) target: \(target)»"
        } else {
            let params = parameters.map({ "\($0.key): \($0.value)" }).joined(separator: " ")
            return "«event \(id) target: \(target) \(params)»"
        }
    }
}
