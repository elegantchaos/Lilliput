// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import CollectionExtensions
import Foundation
import Logger

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
    static let fromParameter = "from"
    static let objectParameter = "object"
    static let toParameter = "to"
}

public class Object {
    let definition: Definition
    let engine: Engine
    var location: Object?
    var position: Position
    var contents: ContentList
    var commands: [Command]
    var observers: Set<Object> = []
    var speakingTo: Set<Object> = []
    var overrides: [String:Any] = [:]
    var behaviourStorage: [String:Any] = [:]
    var containedMass: Double = 0
    var containedVolume: Double = 0
    var maximumMass: Double = .defaultMaximumMass
    var maximumVolume: Double = .defaultMaximumVolume
    
    init(definition: Definition, engine: Engine) {
        self.definition = definition
        self.engine = engine
        self.commands = Self.initialCommands
        self.contents = ContentList()
        self.position = .in
    }
    
    static var initialCommands: [Command] {
        [ExamineCommand()]
    }
    
    var id: String { definition.id }
    
    var names: [String] { definition.names }

    var isPlayer: Bool { definition.id == "player" }
    
    func contains(_ object: Object, recursive: Bool = true) -> Bool { contents.contains(object, recursive: recursive) }
    
    var isCarriedByPlayer: Bool {
        location?.isPlayer == true
    }
    
    var mass: Double {
        definition.mass + containedMass
    }
    
    var volume: Double {
        definition.volume
    }
    
    var locationPair: LocationPair? {
        guard let location = location else { return nil }
        return LocationPair(location: location.id, position: position)
    }
    
    var root: Object {
        var object = self
        while let parent = object.location {
            object = parent
        }
        return object
    }

    func reset() {
        location = nil
        position = .in
        commands = Self.initialCommands
        contents = ContentList()
        overrides = [:]
        behaviourStorage = [:]
        containedMass = 0
        containedVolume = 0
    }
    
    func setup() {
        if let spec = definition.location {
            guard let location = engine.objects[spec.id] else {
                engine.error("Missing location '\(spec.id)' for \(self)")
            }

            move(to: location, position: spec.position)
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
    
    func dump() {
        engine.debug("object: \(id)")
        if let location = location {
            engine.debug("location: \(position) \(location.id)")
        }
        engine.debug("contents: \(contents)")
        if observers.count > 0 {
            engine.debug("observed by: \(observers)")
        }
        engine.debug("properties: \(overrides)")
        engine.debug("behaviours: \(behaviourStorage)")
        engine.debug("mass: contained \(containedMass) max \(maximumMass)")
        engine.debug("volume: contained \(containedVolume) max \(maximumVolume)")
        engine.debug("commands: \(commands.map({ $0.keywords[0] }))")
        
    }
    
    func forEachBehaviour(perform: (Behaviour) -> ()) {
        for id in behaviourStorage.keys {
            let behaviour = engine.behaviours[id]?.init(self, storage: behaviourStorage[id]!)
            perform(behaviour!)
        }
    }


    func didSetup() {
        forEachBehaviour { behaviour in
            behaviour.didSetup()
        }

        if let deferredLocation = definition.properties[asString: "deferredLocation"] {
            guard let location = engine.objects[deferredLocation] else {
                engine.error("Missing location for \(self)")
            }
            
            move(to: location)
        }

    }
    
    func remove(from oldLocation: Object, to newLocation: Object? = nil) {
        oldLocation.contents.remove(self)
        oldLocation.containedMass -= mass
        oldLocation.containedVolume -= volume
        location = nil
        
        var parameters: [String:Any] = [.objectParameter: self]
        if let to = newLocation {
            parameters[.toParameter] = to
        }
        engine.post(event: Event(.contentRemoved, target: oldLocation, parameters: parameters))
    }
    
    func add(to newLocation: Object, position newPosition: Position = .in, from oldLocation: Object? = nil) {
        newLocation.contents.add(self, position: newPosition)
        location = newLocation
        position = newPosition
        newLocation.containedMass += mass
        newLocation.containedVolume += volume
        
        var parameters: [String:Any] = [.objectParameter: self]
        if let from = oldLocation {
            parameters[.fromParameter] = from
        }
        engine.post(event: Event(.contentAdded, target: newLocation, parameters: parameters))
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
        let oldLocation = location
        if (oldLocation != newLocation) || (position != newPosition) {
            var parameters: [String:Any] = [
                .toParameter: newLocation,
                "quiet": quiet
            ]
            
            if let location = oldLocation {
                remove(from: location, to: newLocation)
                parameters[.fromParameter] = location
            }
            
            add(to: newLocation, position: newPosition, from: oldLocation)
            engine.post(event: Event(.moved, target: self, parameters: parameters))
            setProperty(withKey: .locationKey, to: newLocation.id)
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
        
        switch context {
            case .locationContent, .locationContentRecursive:
                return "You can see"
            default:
                return "It contains"
        }
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
        let container = self
        let containerID = id
        
        // for each of our contents we:
        // - skip it if it's the player or the player's location
        // - skip it if it is marked as hidden
        // - show a custom descriptions for the item if there is one
        // - add it to the list of objects to describe briefly
        // - optionally add it to the list of objects to recursively describe the contents of
        
        contents.forEach { object, position in
            if !object.hasFlag(.hiddenFlag) && !object.isPlayer && object != playerLocation {
                object.setFlag(.awareFlag)
                
                // object descriptions for any location
                var customDescriptions = object.getContextDescriptions(for: context)

                // extra descriptions for the object, tagged with this context and container
                // (eg an object's "contained.box" description would be appended
                //  when the context is "contained" and the container's id is "box")
                customDescriptions.append(contentsOf: object.getContextDescriptions(for: "\(context).\(containerID)"))
                
                // extra descriptions when this container contains the object
                customDescriptions.append(contentsOf: container.getContextDescriptions(for: "contains.\(object.id)"))
                
                
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
                if !output.isEmpty { output += "\n\n" }
                output += description
            }
            
        } else {
            var items: [String] = []
            for object in describeBriefly {
                items.append(object.getIndefinite())
            }
            let list = items.joined(separator: ", ")
            if !output.isEmpty { output += "\n\n" }
            output += "\(prefix) \(list)."
        }
        
        let recursiveContext: DescriptionContext
        switch context {
            case .location, .contained: recursiveContext = .containedRecursively
            default: recursiveContext = context
        }
        for object in describeRecursively {
            let description = object.describeContents(context: recursiveContext, showIfEmpty: showIfEmpty || object.hasFlag(.showIfEmptyFlag))
            output += description
        }
        
        return output
    }
    
    func hasVisited(_ location: Object) -> Bool {
        return location.hasFlag(.visitedFlag)
    }

    func playerIsAwareOf(_ object: Object) -> Bool {
        return object.hasFlag(.awareFlag)
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
        return isContentVisible ? describeContents(context: .contained) : ""
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

    func recordTick(for value: String, toPropertyWithKey key: String) {
        var record = getProperty(withKey: key) as? [String:Int] ?? [:]
        record[value] = engine.tick
        setProperty(withKey: key, to: record)
    }
    
    func ticksSince(for value: String, inPropertyWithKey key: String) -> Int {
        let record = getProperty(withKey: key) as? [String:Int]
        guard let lastTick = record?[value] else { return .max }
        return engine.tick - lastTick
    }


    func getObject(withKey key: String) -> Object? {
        let value = getProperty(withKey: key)
        if let object = value as? Object {
            return object
        }
        
        if let string = value as? String {
            if let object = engine.objects[string] {
                return object
            } else {
                engine.warning("Missing object '\(string)' referenced by property '\(key)' of \(self).")
            }
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
    
    func joinConversation(with participants: Set<Object>) {
        let wasSpeakingTo = speakingTo
        speakingTo = wasSpeakingTo.union(participants)
        engine.updateSpeakers(toInclude: speakingTo.union([self]))
        let newPeople = speakingTo.subtracting(wasSpeakingTo)
        for person in newPeople {
            assert(!person.speakingTo.contains(self))
            person.speakingTo.insert(self)
            engine.post(event: Event(.startedTalking, target: person, parameters: [.toParameter: self]))
            engine.post(event: Event(.startedTalking, target: self, parameters: [.toParameter: person]))
        }
    }

    func leaveConversation(with participants: Set<Object>) {
        let newSpeakingTo = speakingTo.subtracting(participants)
        speakingTo = newSpeakingTo
        for person in participants {
            assert(person.speakingTo.contains(self))
            person.speakingTo.remove(self)
            engine.post(event: Event(.stoppedTalking, target: person, parameters: [.toParameter: self]))
            engine.post(event: Event(.stoppedTalking, target: self, parameters: [.toParameter: person]))
        }
        engine.updateSpeakers()
    }
    
    func checkConversations() {
        let reachable = Set(speakingTo.filter(canTalkTo))
        let unreachable = speakingTo.subtracting(reachable)
        if unreachable.count > 0 {
            leaveConversation(with: unreachable)
        }
    }
    
    /// Can two objects talk?
    /// For now this is solely determined by whether they share a location.
    /// Later there might be other mechanisms, such as phones, which allow conversation
    /// over a distance
    /// - Parameter object: The object to test
    func canTalkTo(_ object: Object) -> Bool {
        guard let location = location, let objectLocation = object.location else { return false }

        return location.contains(object) || objectLocation.contains(self)
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

extension Object: EventHandler {
    func forEachBehaviourUntilResult(perform: (Behaviour) -> (EventResult)) -> EventResult {
        var result = EventResult.unhandled
        for id in behaviourStorage.keys {
            let behaviour = engine.behaviours[id]?.init(self, storage: behaviourStorage[id]!)
            result = result.merged(with: perform(behaviour!))
            if result == .swallowed {
                break
            }
        }
        
        return result
    }

    func handle(_ event: Event) -> EventResult {
        var result = forEachBehaviourUntilResult { behaviour in
            return behaviour.handle(event)
        }
        
        if result != .swallowed {
            let context = EventContext(event: event, receiver: self)
            definition.handlers.process(in: context) // TODO: update result?
        }
        
        if result != .swallowed {
            result = defaultHandle(event)
        }

        return result
    }
    
    func defaultHandle(_ event: Event) -> EventResult {
        var result = EventResult.unhandled
        switch EventID(rawValue: event.id) {
        case .startedTalking:
            if let person = event[objectWithKey: .toParameter] {
                dialogueChannel.log("\(self) started talking to \(person)")
                result = .handled
            }
            
        case .stoppedTalking:
            if let person = event[objectWithKey: .toParameter] {
                dialogueChannel.log("\(self) stopped talking to \(person)")
                result = .handled
            }
            
            default:
                break
        }

        return result
    }
}
