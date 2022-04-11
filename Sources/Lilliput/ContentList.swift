// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public enum Position: String, Equatable {
    case `in`
    case on
    case under
    case behind
    case worn
    
    init?(preposition: String) {
        switch preposition {
        case "into": self = .in
        case "onto": self = .on
        default:
            guard let s = Self(rawValue: preposition) else { return nil }
            self = s
        }
    }
}

extension Position: Comparable {
    public static func < (lhs: Position, rhs: Position) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class ContentList {
    var entries: [Object:Position]

    init() {
        entries = [:]
    }

    var objects: [Object] {
        return Array(entries.keys)
    }
    
    var count: Int {
        entries.count
    }
    
    var anyObject: Object? {
        entries.first?.key
    }
    
    var allObjects: [Object] {
        var objects: [Object] = []
        forEach(recursive: true) { object, position in
            objects.append(object)
        }
        return objects
    }

    var allAwareObjects: [Object] {
        var objects: [Object] = []
        forEach(recursingIf: { object in object.hasFlag(.awareFlag) }) { object, position in
            objects.append(object)
        }
        return objects
    }

    var allVisibleObjects: [Object] {
        var objects: [Object] = []
        forEach(recursingIf: { object in (OpenableBehaviour(object) == nil) || object.hasFlag(.openedFlag) }) { object, position in
            objects.append(object)
        }
        return objects
    }

    var allEntries: ContentList {
        let contents = ContentList()
        forEach(recursive: true) { object, position in
            contents.add(object, position: position)
        }
        return contents
    }

    func add(_ object: Object, position: Position) {
        entries[object] = position
    }
    
    func remove(_ object: Object) {
        entries.removeValue(forKey: object)
    }
    
    func merge(_ contents: ContentList) {
        entries.mergeReplacingDuplicates(contents.entries)
    }
    
    func contains(_ object: Object, recursive: Bool = true) -> Bool {
        if entries[object] != nil {
            return true
        }

        if recursive {
            for carried in entries {
                if carried.key.contains(object) {
                    return true
                }
            }
        }

        return false
    }
    
    func forEach(recursive: Bool = false, perform: (Object, Position) -> ()) {
        let sorted = entries.keys.sorted(by: \.id)
        for object in sorted {
            let position = entries[object]!
            perform(object, position)
            if recursive {
                object.contents.forEach(recursive: recursive, perform: perform)
            }
        }
    }
    
    func forEach(recursingIf: (Object) -> Bool, perform: (Object, Position) -> ()) {
        let sorted = entries.keys.sorted(by: \.id)
        for object in sorted {
            let position = entries[object]!
            perform(object, position)
            if recursingIf(object) {
                object.contents.forEach(recursingIf: recursingIf, perform: perform)
            }
        }
    }

}
