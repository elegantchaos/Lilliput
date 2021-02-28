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
    var commands: [Command]
    var overrides: [String:Any] = [:]
    
    init(definition: Definition, engine: Engine) {
        self.definition = definition
        self.engine = engine
        self.commands = [ExamineCommand()]
    }
    
    var id: String { definition.id }
    
    var names: [String] { definition.names }

    var completeContents: [Object] {
        var objects: [Object] = []
        for object in contents {
            objects.append(object)
            objects.append(contentsOf: object.completeContents)
        }
        
        return objects
    }
    
    func setup() {
        if let locationId = definition.properties[stringWithKey: "location"] {
            guard let location = engine.objects[locationId] else { engine.error("Missing location for \(self)")}
            add(to: location)
        }
        
        if let kind = definition.properties[stringWithKey: "type"] {
            switch kind {
                case "player":
                    commands.append(ExamineCommand(shouldMatchTarget: false))
                    
                default:
                    break
            }
        }
    }
    
    func remove(from object: Object) {
        object.contents.remove(self)
        location = nil
        engine.post(event: Event(id: "contentRemoved", target: object, parameters: ["object": self]))
        engine.post(event: Event(id: "movedFrom", target: self, parameters: ["container": object]))
    }
    
    func add(to object: Object) {
        object.contents.insert(self)
        location = object
        engine.post(event: Event(id: "contentAdded", target: object, parameters: ["object": self]))
        engine.post(event: Event(id: "movedTo", target: self, parameters: ["container": object]))
    }
    
    func move(to newLocation: Object) {
        if location != newLocation {
            if let location = location {
                remove(from: location)
            }
            
            add(to: newLocation)
        }
    }
    
    func getDescription(for context: String) -> String {
        if let string = definition.strings[context] {
            return string
        }
        
        engine.warning("Missing \(context) string for \(self)")
        return id
    }
    
    func showContents(context: String, prefix: String) {
        
    }
    
    func showExits() {
        
    }
    
    func showDescription(context: String, prefix: String) {
        
    }
    
    func showDescriptionAndContents() {
        engine.output(id)
    }
    
    func showLocation() {
        var locations: [Object] = []
        var context = "location"
        var prefix = ""
        var next = self.location
        while let location = next {
            locations.append(location)
            location.showDescription(context: context, prefix: prefix)
            next = location.location
            if next != nil {
                context = "container"
                prefix = location.getDescription(for: "outside")
            }
        }

        for location in locations {
            location.showContents(context: "location", prefix: "You can see")
            location.showExits()
        }
    }
    
    func getProperty(withKey key: String) -> Any? {
        return overrides[key] ?? definition.properties[key]
    }
    
    func setProperty(withKey key: String, to value: Any) {
        overrides[key] = value
    }
    
    func setFlag(_ key: String) {
        setProperty(withKey: key, to: true)
    }
    
    func clearFlag(_ key: String) {
        setProperty(withKey: key, to: false)
    }
    
    func hasFlag(_ key: String) -> Bool {
        (getProperty(withKey: key) as? Bool) == true
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

extension Object: CustomStringConvertible {
    public var description: String {
        "«\(id)»"
    }
}

extension Object: CommandOwner {
}
