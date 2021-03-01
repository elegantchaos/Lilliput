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
    var traits: [String:Trait.Type] = [:]
    
    lazy var exits: [String:Exit] = setupExits()
    
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
    
    func setupExits() -> [String:Exit] {
        var exits: [String:Exit] = [:]
        for exit in definition.exits {
            if let destination = engine.objects[exit.value] {
                exits[exit.key] = Exit(to: destination)
            } else {
                engine.warning("Missing exit \(exit.value) for \(self).")
            }
        }
        return exits
    }
    
    func setup() {
        if let locationId = definition.properties[stringWithKey: "location"] {
            guard let location = engine.objects[locationId] else { engine.error("Missing location for \(self)")}
            add(to: location)
        }
        
        for trait in engine.traits.values {
            let id = trait.id
            if (definition.kind == id) || definition.hasFlag(id) {
                traits[id] = trait
            }
        }
        
        for trait in traits.values {
            commands.append(contentsOf: trait.commands)
        }
    }
    
    func link() {
        switch definition.kind {
            case "portal":
                break // TODO: setup portal
            
            default:
                break
        }
    }
    
    func remove(from object: Object) {
        object.contents.remove(self)
        location = nil
        engine.post(event: Event(id: .contentRemoved, target: object, parameters: ["object": self]))
        engine.post(event: Event(id: .movedFrom, target: self, parameters: ["container": object]))
    }
    
    func add(to object: Object) {
        object.contents.insert(self)
        location = object
        engine.post(event: Event(id: .contentAdded, target: object, parameters: ["object": self]))
        engine.post(event: Event(id: .movedTo, target: self, parameters: ["container": object]))
    }
    
    func move(to newLocation: Object) {
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
    
    func getExitDescription(exit: Exit, direction: String) -> String {
        var description = direction
        
        if let portal = exit.portal {
            let brief = portal.getDescriptionWarnIfMissing(for: .exit)
            description += " \(brief)"
        }
        
        if engine.player.hasVisited(location: exit.destination) {
            let brief = exit.destination.getDefinite()
            description += " to \(brief)"
        }

        return description
    }
    
    func showExits() {
        let count = exits.count
        if count > 0 {
            let start = count == 1 ? "There is a single exit " : "There are exits "
            
            var body: [String] = []
            for exit in exits {
                let string = getExitDescription(exit: exit.value, direction: exit.key)
                body.append(string)
            }
            
            let list = body.joined(separator: ", ")
            engine.output("\(start)\(list).")
        }
    }
    
    func hasFlagMatchingKey(_ key: String) -> Bool {
        if hasFlag(key) {
            return true
        }
        
        return key.starts(with: "not-") && hasFlag(String(key.dropFirst(4)))
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
        if hasFlag("open") || !hasFlag("openable") {
            let prefix = getContentPrefix()
            showContents(prefix: prefix)
        }
    }
    
    func showDescriptionAndContents() {
        showDescription(context: .detailed)
        engine.output(id)
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
    
    func trait<T>(_ kind: T.Type) -> T.Type? where T: Trait {
        traits[id] as? T.Type
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
