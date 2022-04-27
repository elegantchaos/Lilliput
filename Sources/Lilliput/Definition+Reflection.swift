// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension Definition {
    static let labels = [
        "strings.definite": "Definite Name",
        "strings.indefinite": "Indefinite Name",
        "strings.location": "Location Description",
        "strings.detailed": "Object Description"
    ]

    var generalDescriptionKeys: [String] {
        return ["indefinite", "definite", "detailed"]
    }
    
    func label(forPath path: String) -> String {

        return Self.labels[path] ?? path
    }
    
    func pathIsMultiline(_ path: String) -> Bool {
        switch path {
            case "strings.detailed", "strings.location":
                return true
                
            default:
                return false
        }
    }
}
