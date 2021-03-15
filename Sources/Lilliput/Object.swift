// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import CollectionExtensions
import Foundation

extension Double {
    static let defaultMaximumMass = 100.0
    static let defaultMaximumVolume = 100.0
}

extension String {
    static let hiddenFlag = "hidden"
    static let showIfEmptyFlag = "showEmpty"
    static let skipBriefFlag = "skipBrief"
    static let showContentModeProperty = "showContentWhen"
    static let showContentAlwaysMode = "always"
    static let containerParameter = "container"
    static let objectParameter = "object"
}

public class Object {
    let definition: Definition
    let engine: Engine
    var location: Object?
    var position: Position
    var contents: ContentList
    var commands: [Command]
    var observers: Set<Object> = []
    var overrides: [String:Any] = [:]
    var behaviourStorage: [String:Any] = [:]
    var containedMass: Double = 0
    var containedVolume: Double = 0
    var maximumMass: Double = .defaultMaximumMass
    var maximumVolume: Double = .defaultMaximumVolume
    
    init(definition: Definition, engine: Engine) {
        self.definition = definition
        self.engine = engine
        self.commands = [ExamineCommand()]
        self.contents = ContentList()
        self.position = .in
    }
    
    var id: String { definition.id }
    
    var names: [String] { definition.names }

    var isPlayer: Bool { definition.id == "player" }
    
    func contains(_ object: Object) -> Bool { contents.contains(object) }
    
    var isCarriedByPlayer: Bool {
        location?.isPlayer == true
    }
    
    var mass: Double {
        definition.mass + containedMass
    }
    
    var volume: Double {
        definition.volume
    }
    
    func setup() {
        if let spec = definition.location {
            guard let location = engine.objects[spec.id] else { engine.error("Missing location '\(spec.id)' for \(self)")}
            add(to: location, position: spec.position)
        }
        
        for id in definition.traits {
            if let behaviour = engine.behaviours[id] {
                behaviourStorage[id] = behaviour.storage(for: self)
                commands.append(contentsOf: behaviour.commands)
            } else {
                engine.warning("Unknown trait \(id).")
            }
        }
    }
    

    func forEachBehaviour(perform: (Behaviour) -> ()) {
        for id in behaviourStorage.keys {
            let behaviour = engine.behaviours[id]?.init(self, storage: behaviourStorage[id]!)
            perform(behaviour!)
        }
    }


    func forEachBehaviourUntilTrue(perform: (Behaviour) -> (Bool)) -> Bool {
        for id in behaviourStorage.keys {
            let behaviour = engine.behaviours[id]?.init(self, storage: behaviourStorage[id]!)
            if perform(behaviour!) {
                return true
            }
        }
        
        return false
    }

    func didSetup() {
        forEachBehaviour { behaviour in
            behaviour.didSetup()
        }

        if let deferredLocation = definition.properties[asString: "deferredLocation"] {
            guard let location = engine.objects[deferredLocation] else { engine.error("Missing location for \(self)")}
            add(to: location)
        }

    }
    
    func remove(from oldLocation: Object) {
        oldLocation.contents.remove(self)
        oldLocation.containedMass -= mass
        oldLocation.containedVolume -= volume
        location = nil
        engine.post(event: Event(id: .contentRemoved, target: oldLocation, parameters: [.objectParameter: self]))
        engine.post(event: Event(id: .movedFrom, target: self, parameters: [.containerParameter: oldLocation]))
    }
    
    func add(to newLocation: Object, position newPosition: Position = .in) {
        newLocation.contents.add(self, position: position)
        location = newLocation
        position = newPosition
        newLocation.containedMass += mass
        newLocation.containedVolume += volume
        
        engine.post(event: Event(id: .contentAdded, target: newLocation, parameters: [.objectParameter: self]))
        engine.post(event: Event(id: .movedTo, target: self, parameters: [.containerParameter: newLocation]))
    }
    
    func add(observer: Object) {
        observerChannel.log("Added \(observer) as observer for \(self)")
        observers.insert(observer)
    }
    
    func remove(observer: Object) {
        observerChannel.log("Removed \(observer) as observer for \(self)")
        observers.remove(observer)
    }
    
    func move(to newLocation: Object, position newPosition: Position = .in, quiet: Bool = false) {
        if (location != newLocation) || (position != newPosition) {
            if let location = location {
                remove(from: location)
            }
            
            add(to: newLocation, position: newPosition)
        }
    }
    
    func handle(_ event: Event) -> Bool {
        return forEachBehaviourUntilTrue { behaviour in
            return behaviour.handle(event)
        }
    }

    func getContextDescriptions(for context: DescriptionContext) -> [String] {
        guard context != .none else { return [] }
        return getContextDescriptions(for: context.rawValue)
    }
    
    func getContextDescriptions(for context: String) -> [String] {
        var descriptions: [String] = []

        let isExamined = hasFlag(.examinedFlag)
        let exContext = isExamined ? "\(context)-examined" : "\(context)-not-examined"
        if let description = getDescription(for: exContext) {
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
    
    func describeContents(context: DescriptionContext = .none, showIfEmpty: Bool = false) -> String {
        // get a phrase like "You can see", or "It contains" to prefix the contents with
        let prefix = getContentPrefix(for: context)

        var output = ""
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
                object.setFlag(.awareFlag)
                var customDescriptions = object.getContextDescriptions(for: context)
                if context == .location, let id = object.location?.id {
                    customDescriptions.append(contentsOf: object.getContextDescriptions(for: "location.\(id)"))
                }
                if customDescriptions.count > 0 {
                    for description in customDescriptions {
                        output += description
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
                output += description
            }
            
        } else {
            var items: [String] = []
            for object in describeBriefly {
                items.append(object.getIndefinite())
            }
            let list = items.joined(separator: ", ")
            output += "\(prefix) \(list)."
        }
        
        for object in describeRecursively {
            let description = describeContents(context: context, showIfEmpty: showIfEmpty || object.hasFlag(.showIfEmptyFlag))
            output += description
        }
        
        return output
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
    
    func getDescription(context: DescriptionContext, prefix: String = "") -> String {
        
        let description = prefix + getDescriptionWarnIfMissing(for: context)
        var output = description
        
        for string in definition.strings {
            if hasFlagMatchingKey(string.key) {
                output += string.value
            }
        }
        
        return output
    }
    
    func getContentsIfVisible() -> String {
        return isContentVisible ? describeContents() : ""
    }
    
    var isContentVisible: Bool {
        OpenableBehaviour(self)?.isContentVisible ?? true
    }
    
    func getDescriptionAndContents() -> String {
        var output = getDescription(context: .detailed)
        output += getContentsIfVisible()
        return output
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

    func getStrings(withKey key: String) -> [String] {
        (getProperty(withKey: key) as? [String]) ?? []
    }

    func property(withKey key: String, contains value: String) -> Bool {
        guard let list = getProperty(withKey: key) as? [String] else { return false }
        return list.contains(value)
    }
    
    func append(_ value: String, toPropertyWithKey key: String) {
        var list = getProperty(withKey: key) as? [String] ?? []
        if !list.contains(value) {
            list.append(value)
            setProperty(withKey: key, to: list)
        }
    }
    
    func remove(_ value: String, fromPropertyWithKey key: String) {
        guard var list = getProperty(withKey: key) as? [String] else { return }
        if let index = list.firstIndex(of: value) {
            list.remove(at: index)
            setProperty(withKey: key, to: list)
        }
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
