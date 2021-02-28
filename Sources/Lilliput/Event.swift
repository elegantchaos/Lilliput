// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Event {
    let id: String
    let target: Object
    let parameters: [String:Any]

    internal init(id: String, target: Object, parameters: [String : Any] = [:]) {
        self.id = id
        self.target = target
        self.parameters = parameters
    }
}

extension Event: CustomStringConvertible {
    var description: String {
        let params = parameters.count > 0 ? " params: \(parameters)" : ""
        return "«event \(id) target: \(target)\(params)»"
    }
}
