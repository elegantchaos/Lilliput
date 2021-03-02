// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

enum Position: String {
    case `in`
    case on
    case worn
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
    
    func contains(_ object: Object) -> Bool {
        if entries[object] != nil {
            return true
        }

        for carried in entries {
            if carried.key.contains(object) {
                return true
            }
        }

        return false
    }
    
    func forEach(recursive: Bool = false, perform: (Object, Position) -> ()) {
        for entry in entries {
            perform(entry.key, entry.value)
            if recursive {
                entry.key.contents.forEach(recursive: recursive, perform: perform)
            }
        }
    }
}
