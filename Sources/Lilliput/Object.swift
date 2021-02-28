// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation

public class Object {
    let definition: Definition
    let engine: Engine
    var location: Object?
    var contents: Set<Object> = []
    
    init(definition: Definition, engine: Engine) {
        self.definition = definition
        self.engine = engine
    }
    
    var id: String { definition.id }
    
    func setup() {
        if let locationId = definition.properties[stringWithKey: "location"] {
            guard let location = engine.objects[locationId] else { engine.error("Missing location for \(self)")}
            add(to: location)
        }
    }
    
    func remove(from object: Object) {
        object.contents.remove(self)
        location = nil
        engine.post(event: Event(id: "contentRemoved", target: object, parameters: ["object": self]))
        engine.post(event: Event(id: "movedFrom", target: self, parameters: ["container": object]))
    }
    
    func add(to object: Object) {
        object.contents.insert(object)
        location = object
        engine.post(event: Event(id: "contentAdded", target: object, parameters: ["object": self]))
        engine.post(event: Event(id: "movedTo", target: self, parameters: ["container": object]))
    }
    
    func move(to newLocation: Object) {
        if let location = location {
            remove(from: location)
        }
        
        add(to: newLocation)
    }
}

extension Object: Equatable {
    public static func == (lhs: Object, rhs: Object) -> Bool {
        lhs.definition.id == rhs.definition.id
    }
    
    
}
extension Object: Hashable {
    public func hash(into hasher: inout Hasher) {
        definition.id.hash(into: &hasher)
    }
}
