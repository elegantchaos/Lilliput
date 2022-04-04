// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

infix operator ???

func ???<T, P>(_ p: Optional<T>, t: (T) -> P?) -> P? {
    return p.flatMap(t)
}

extension String {
    var sentenceCased: String {
        guard let first = self.first else { return self }
        
        var copy = String(first.uppercased())
        copy.append(contentsOf: self[index(after: startIndex)...])
        return copy
    }
}
