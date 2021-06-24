// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

infix operator ???

func ???<T, P>(_ p: Optional<T>, t: (T) -> P?) -> P? {
    return p.flatMap(t)
}

public protocol InitMappable {
    associatedtype FromType
    init(_ from: FromType)
}

extension Collection {
    public func map<T>(as type: T.Type) -> [T]  where T: InitMappable, T.FromType == Element {
        self.map({ T($0) })
    }
}

extension String: InitMappable {
    public typealias FromType = Substring
}

extension String {
    var sentenceCased: String {
        guard let first = self.first else { return self }
        
        var copy = String(first.uppercased())
        copy.append(contentsOf: self[index(after: startIndex)...])
        return copy
    }
}
