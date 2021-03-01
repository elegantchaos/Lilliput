// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Files
import Foundation

public class Engine {
    let driver: Driver
    var running = true
    var definitions: [String:Definition] = [:]
    var objects: [String:Object] = [:]
    var player: Object!
    var events: [Event] = []
    var traits: [String:Trait.Type] = [:]
    
    public init(driver: Driver) {
        self.driver = driver
        registerStandardTraits()
    }
    
    public func registerStandardTraits() {
        register(trait: LocationTrait.self)
        register(trait: LockableTrait.self)
        register(trait: MovableTrait.self)
        register(trait: OpenableTrait.self)
        register(trait: PersonTrait.self)
        register(trait: PlayerTrait.self)
        register(trait: PortalTrait.self)
        register(trait: SittableTrait.self)
        register(trait: WearableTrait.self)
    }
    
    public func load(url: URL) {
        let folder = FileManager.default.locations.folder(for: url)
        do {
            try folder.forEach { item in
                if let file = item as? ThrowingFile {
                    let definitions = DefinitionsFile(file: file)
                    try definitions.load(into: self)
                }
            }
        } catch {
                driver.error("\(error)")
        }
            
    }

    public func output(_ string: String) {
        driver.output(string)
    }
    
    public func warning(_ string: String) {
        driver.warning(string)
    }
    
    public func error(_ string: String) -> Never {
        driver.error(string)
        exit(1)
    }
    
    func post(event: Event) {
        events.append(event)
    }
    
    func setupObjects() {
        for definition in definitions {
            let object = Object(definition: definition.value, engine: self)
            objects[definition.key] = object
        }
        
        for object in objects.values {
            object.setup()
        }
        
        for object in objects.values {
            object.didSetup()
        }
        
        if let player = objects["player"] {
            self.player = player
        } else {
            error("Couldn't find player object.")
        }
    }
    
    func inputCandidates() -> [CommandOwner] {
        var candidates: [CommandOwner] = []
        
        if let location = player.location {
            candidates.append(contentsOf: Array(location.completeContents))
            candidates.append(location)
        }
        candidates.append(self)
        
        return candidates
    }
    
    
    func handleInput() {
        let input = driver.getInput()
        let candidates = inputCandidates()
        for object in candidates {
            let context = Context(input: input, target: object, engine: self)
            for command in object.commands {
                if command.matches(context) {
                    command.perform(in: context)
                    return
                }
            }
        }
        
        output("I don't know how to \(input.raw)!")
    }
    
    func deliver(_ event: Event, to object: Object) -> Bool {
        if object.handle(event) {
            return true
        }
        
        if event.propogates, let parent = object.location {
            return deliver(event, to: parent)
        }
        
        return false
    }
    
    func handleEvents() {
        if events.count == 0 {
            events.append(Event(id: "idle", target: player))
        }
        
        for event in events {
            _ = deliver(event, to: event.target)
        }
        
        events = []
    }
    
    public func run() {
        setupObjects()

        while running {
            handleEvents()
            handleInput()
        }
        
        output("Bye.")
    }
    
    func register(definition: Definition) {
        definitions[definition.id] = definition
        print("registered \(definition.id)")
    }
    
    func register(trait: Trait.Type) {
        traits[trait.id] = trait
    }
}

extension Engine: CommandOwner {
    var commands: [Command] {
        return [QuitCommand()]
    }
    
    var names: [String] { [] }
}
