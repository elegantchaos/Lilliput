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

    var isPlayer: Bool { definition.id == "player" }
    
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
    
    func getContextDescriptions(for context: DescriptionContext) -> [String] {
        []
    }
    
    func getDescriptionWarnIfMissing(for context: DescriptionContext) -> String {
        if let description = getDescription(for: context) {
            return description
        }

        engine.warning("Missing \(context) string for \(self)")
        return id
    }
    
    func getDefinite() -> String {
        return getDescriptionWarnIfMissing(for: .definite)
    }
    
    func getIndefinite() -> String {
        return getDescriptionWarnIfMissing(for: .indefinite)
    }
    
    func getContentPrefix(for context: DescriptionContext = .none) -> String {
        if context != .none, let prefix = getDescription(for: "contentPrefix-\(context)") {
            return prefix
        }
        
        return getDescription(for: .contentPrefix) ?? "It contains"
    }
    
    func getDescription(for context: String) -> String? {
        return definition.strings[context]
    }
    
    func getDescription(for context: DescriptionContext) -> String? {
        return definition.strings[context.rawValue]
    }
    
    func showContents(context: DescriptionContext, prefix: String, showIfEmpty: Bool = false) {
        var objects: [Object] = []
        var recursive: [Object] = []
        
        let playerLocation = engine.player.location
        
        for object in contents {
            if !object.hasFlag("hidden") && !object.isPlayer && object != playerLocation {
                let descriptions = object.getContextDescriptions(for: context)
                if descriptions.count == 0 && !object.hasFlag("skipBrief") {
                    objects.append(object)
                } else {
                    for description in descriptions {
                        engine.output(description)
                    }
                }
                
                let mode = object.getString(withKey: "showContext")
                if (mode == "always") || object.hasFlag(mode) {
                    recursive.append(object)
                }
            }
        }
        
        if objects.count == 0 {
            if showIfEmpty {
                let description = getDescription(for: .contentEmpty) ?? "\(prefix) nothing."
                engine.output(description)
            }
            
        } else {
            var briefs: [String] = []
            for object in objects {
                briefs.append(object.getIndefinite())
            }
            let objectDescriptions = briefs.joined(separator: ", ")
            engine.output("\(prefix) \(objectDescriptions)")
        }
        
        for object in recursive {
            let prefix = object.getContentPrefix(for: context)
            object.showContents(context: context, prefix: prefix, showIfEmpty: showIfEmpty || object.hasFlag("showEmpty"))
        }
    }
    
    func showExits() {
        
    }
    
    func showDescription(context: DescriptionContext, prefix: String) {
        
    }
    
    func showDescriptionAndContents() {
        engine.output(id)
    }
    
    func showLocation() {
        var locations: [Object] = []
        var context = DescriptionContext.location
        var prefix = ""
        var next = self.location
        while let location = next {
            locations.append(location)
            location.showDescription(context: context, prefix: prefix)
            next = location.location
            if next != nil {
                context = .container
                prefix = location.getDescription(for: .outside) ?? ""
            }
        }

        for location in locations {
            location.showContents(context: .location, prefix: "You can see")
            location.showExits()
        }
    }
    
    func getProperty(withKey key: String) -> Any? {
        return overrides[key] ?? definition.properties[key]
    }
    
    func setProperty(withKey key: String, to value: Any) {
        overrides[key] = value
    }
    
    func getString(withKey key: String) -> String {
        (getProperty(withKey: key) as? String) ?? ""
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
