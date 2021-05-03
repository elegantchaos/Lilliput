// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

enum EventID: String {
    case contentAdded
    case contentRemoved
    case loaded
    case moved
    case played
    case replied
    case sat
    case shot
    case used
}

enum EventResult {
    case unhandled
    case handled
    case swallowed
    
    func merged(with other: EventResult) -> Self {
        if (self == .swallowed) || (other == .swallowed) {
            return .swallowed
        }
        
        return (self == .unhandled) ? other : self
    }
}

protocol EventHandler {
    func handle(_ event: Event) -> EventResult
}

struct Event {
    let id: String
    let target: Object
    let propogates: Bool
    fileprivate let parameters: [String:Any]

    init(_ id: EventID, target: Object, propogates: Bool = false, parameters: [String:Any] = [:]) {
        self.init(id: id.rawValue, target: target, propogates: propogates, parameters: parameters)
    }
    
    init(id: String, target: Object, propogates: Bool = false, parameters: [String : Any] = [:]) {
        self.id = id
        self.target = target
        self.propogates = propogates
        self.parameters = parameters
    }
    
    func `is`(_ id: EventID) -> Bool {
        return self.id == id.rawValue
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

    subscript(boolWithKey key: String) -> Bool {
        get {
            return parameters[asBool: key] ?? false
        }
    }

    subscript(rawWithKey key: String) -> Any? {
        get {
            return parameters[key]
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
