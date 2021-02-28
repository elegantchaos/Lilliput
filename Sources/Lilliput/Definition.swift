// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Definition {
    let id: String
    let strings: [String:String]
    let properties: [String:Any]
    
    init(id: String, properties: [String:Any]) {
        self.id = id
        self.properties = properties
        if let strings = properties["strings"] as? [String:String] {
            self.strings = strings
        } else {
            self.strings = [:]
        }
    }
}

