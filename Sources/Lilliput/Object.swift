// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import CollectionExtensions
import Foundation

extension String {
    static let hiddenFlag = "hidden"
    static let showIfEmptyFlag = "showEmpty"
    static let skipBriefFlag = "skipBrief"
    static let showContentModeProperty = "showContentWhen"
    static let showContentAlwaysMode = "always"
}

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
        guard context != .none else { return [] }
        
        var descriptions: [String] = []

        let isExamined = hasFlag(.examinedFlag)
        let context = isExamined ? "\(context)-examined" : "\(context)-not-examined"
        if let description = getDescription(for: context) {
            descriptions.append(description)
        }

        if let description = getDescription(for: context) {
            descriptions.append(description)
        }
        
        return descriptions
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
        
        if let prefix = getDescription(for: .contentPrefix) {
            return prefix
        }
        
        return (context == .location) ? "You can see" : "It contains"
    }
    
    func getDescription(for context: String) -> String? {
        return definition.strings[context]
    }
    
    func getDescription(for context: DescriptionContext) -> String? {
        return definition.strings[context.rawValue]
    }
    
    func showContents(context: DescriptionContext = .none, showIfEmpty: Bool = false) {
        // get a phrase like "You can see", or "It contains" to prefix the contents with
        let prefix = getContentPrefix(for: context)

        var describeBriefly: [Object] = []
        var describeRecursively: [Object] = []
        let playerLocation = engine.player.location
        
        // for each of our contents we:
        // - skip it if it's the player or the player's location
        // - skip it if it is marked as hidden
        // - show a custom descriptions for the item if there is one
        // - add it to the list of objects to describe briefly
        // - optionally add it to the list of objects to recursively describe the contents of
        
        contents.forEach { object, position in
            if !object.hasFlag(.hiddenFlag) && !object.isPlayer && object != playerLocation {
                let customDescriptions = object.getContextDescriptions(for: context)
                if customDescriptions.count > 0 {
                    for description in customDescriptions {
                        engine.output(description)
                    }
                    
                } else if !object.hasFlag(.skipBriefFlag) {
                    describeBriefly.append(object)
                }
                
                let mode = object.getString(withKey: .showContentModeProperty)
                if (mode == .showContentAlwaysMode) || object.hasFlag(mode) {
                    describeRecursively.append(object)
                }
            }
        }
        
        if describeBriefly.count == 0 {
            if showIfEmpty {
                let description = getDescription(for: .contentEmpty) ?? "\(prefix) nothing."
                engine.output(description)
            }
            
        } else {
            var items: [String] = []
            for object in describeBriefly {
                items.append(object.getIndefinite())
            }
            let list = items.joined(separator: ", ")
            engine.output("\(prefix) \(list).")
        }
        
        for object in describeRecursively {
            object.showContents(context: context, showIfEmpty: showIfEmpty || object.hasFlag(.showIfEmptyFlag))
        }
    }
    
    func hasVisited(location: Object) -> Bool {
        return location.hasFlag(.visitedFlag)
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
            showContents()
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
