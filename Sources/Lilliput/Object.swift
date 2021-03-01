// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import CollectionExtensions
import Foundation


public class Object {
    let definition: Definition
    let engine: Engine
    var location: Object?
    var contents: ContentList
    var commands: [Command]
    var overrides: [String:Any] = [:]
    var traits: [String:Trait] = [:]
    
    init(definition: Definition, engine: Engine) {
        self.definition = definition
        self.engine = engine
        self.commands = [ExamineCommand()]
        self.contents = ContentList()
    }
    
    var id: String { definition.id }
    
    var names: [String] { definition.names }

    var isPlayer: Bool { definition.id == "player" }
    
    func contains(_ object: Object) -> Bool { contents.contains(object) }
    
    var isCarriedByPlayer: Bool {
        location?.isPlayer == true
    }
    
    func setup() {
        let id: String?
        var position = Position.in
        if let spec = definition.properties["location"] as? [String] {
            id = spec.first
            if spec.count > 1, let pos = Position(rawValue: spec[1]) {
                position = pos
            }
        } else {
            id = definition.properties[stringWithKey: "location"]
        }

        if let id = id {
            guard let location = engine.objects[id] else { engine.error("Missing location for \(self)")}
            add(to: location, position: position)
        }
        
        for trait in engine.traits.values {
            let id = trait.id
            if (definition.kind == id) || definition.hasFlag(id) {
                traits[id] = trait.init(with: self)
            }
        }
        
        for trait in traits.values {
            commands.append(contentsOf: trait.commands)
        }
    }
    
    func didSetup() {
        for trait in traits.values {
            trait.didSetup(self)
        }
    }
    
    func remove(from object: Object) {
        object.contents.remove(self)
        location = nil
        engine.post(event: Event(id: .contentRemoved, target: object, parameters: ["object": self]))
        engine.post(event: Event(id: .movedFrom, target: self, parameters: ["container": object]))
    }
    
    func add(to object: Object, position: Position = .in) {
        object.contents.add(self, position: position)
        location = object
        engine.post(event: Event(id: .contentAdded, target: object, parameters: ["object": self]))
        engine.post(event: Event(id: .movedTo, target: self, parameters: ["container": object]))
    }
    
    func move(to newLocation: Object, position: String = "in", quiet: Bool = false) {
        if location != newLocation {
            if let location = location {
                remove(from: location)
            }
            
            add(to: newLocation)
        }
    }
    
    func handle(_ event: Event) -> Bool {
        for trait in traits.values {
            if trait.handle(event) {
                return true
            }
        }
        
        return false
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
    
    func showContents(context: DescriptionContext = .none, prefix: String, showIfEmpty: Bool = false) {
        var objects: [Object] = []
        var recursive: [Object] = []
        
        let playerLocation = engine.player.location
        
        contents.forEach { object, position in
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
            var items: [String] = []
            for object in objects {
                items.append(object.getIndefinite())
            }
            let list = items.joined(separator: ", ")
            engine.output("\(prefix) \(list).")
        }
        
        for object in recursive {
            let prefix = object.getContentPrefix(for: context)
            object.showContents(context: context, prefix: prefix, showIfEmpty: showIfEmpty || object.hasFlag("showEmpty"))
        }
    }
    
    func hasVisited(location: Object) -> Bool {
        return false // TODO:
    }
        
    func hasFlagMatchingKey(_ key: String) -> Bool {
        if hasFlag(key) {
            return true
        }
        
        return key.starts(with: "not-") && !hasFlag(String(key.dropFirst(4)))
    }
    
    func showDescription(context: DescriptionContext, prefix: String = "") {
        let description = prefix + getDescriptionWarnIfMissing(for: context)
        engine.output(description)
        
        for string in definition.strings {
            if hasFlagMatchingKey(string.key) {
                engine.output(string.value)
            }
        }
    }
    
    func showContentsIfVisible() {
        if isContentVisible {
            let prefix = getContentPrefix()
            showContents(prefix: prefix)
        }
    }
    
    func showDescriptionAndContents() {
        showDescription(context: .detailed)
        showContentsIfVisible()
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
    
    func getObject(withKey key: String) -> Object? {
        let value = getProperty(withKey: key)
        if let object = value as? Object {
            return object
        }
        
        if let string = value as? String, let object = engine.objects[string] {
            return object
        }
        
        return nil
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
    
    func aspect<T>(_ kind: T.Type) -> T? where T: Trait {
        traits[kind.id] as? T
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
