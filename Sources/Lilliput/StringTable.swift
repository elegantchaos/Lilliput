// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct StringTable {
    public typealias Index = [String:StringAlternatives]
    public let table: Index
    
    var keys: Index.Keys {
        table.keys
    }
    
    init(from data: Any?) {
        var filtered: Index = [:]
        if let items = (data as? [String:Any]) {
            for item in items {
                if let strings = StringAlternatives(item.value) {
                    filtered[item.key] = strings
                }
            }
        }
        table = filtered
    }
    
    func alternatives(for key: String) -> StringAlternatives? {
        return table[key]
    }
    
    public var asInterchange: [String: Any] {
        return table.mapValues({ $0.asInterchange })
    }
}

public struct StringAlternatives {
    public let strings: [String]
    
    init?(_ data: Any?) {
        if let string = data as? String {
            self.strings = [string]
        } else if let strings = data as? [String] {
            self.strings = strings
        } else {
            return nil
        }
    }
    
    var asInterchange: Any {
        if strings.count == 1 {
            return strings[0]
        } else {
            return strings
        }
    }
}

