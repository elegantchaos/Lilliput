// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Files
import Foundation
import Logger

let eventChannel = Channel("Events")
let observerChannel = Channel("Observers")
let engineChannel = Channel("Engine")

extension String {
    static let gameFileExtension = "json"
}

public class Engine {
    let driver: Driver
    var running = true
    var definitions: [String:Definition] = [:]
    var objects: [String:Object] = [:]
    var player: Object!
    var events: [Event] = []
    var behaviours: [String:Behaviour.Type] = [:]
    var speech: [Dialogue.Output] = []
    var tick = 0
    
    public init(driver: Driver) {
        self.driver = driver
        registerStandardBehaviours()
    }
    
    public func registerStandardBehaviours() {
        register(LocationBehaviour.self)
        register(LockableBehaviour.self)
        register(MovableBehaviour.self)
        register(OpenableBehaviour.self)
        register(PersonBehaviour.self)
        register(PlayerBehaviour.self)
        register(PortalBehaviour.self)
        register(SittableBehaviour.self)
        register(WearableBehaviour.self)
    }
    
    func register(_ definition: Definition) {
        definitions[definition.id] = definition
        engineChannel.log("registered object \(definition.id)")
    }
    
    func register<T>(_ behaviour: T.Type) where T: Behaviour {
        behaviours[behaviour.id] = behaviour
        engineChannel.log("registered behaviour \(behaviour.id)")
    }
    
    public func load(url: URL) {
        
        let folder = ThrowingManager.folder(for: url)
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
        
        let objectIds = definitions.keys.sorted()

        var created: [Object] = []
        for id in objectIds {
            let object = Object(definition: definitions[id]!, engine: self)
            created.append(object)
            objects[id] = object
        }
        
        for object in created {
            object.setup()
        }

        if let player = objects["player"] {
            self.player = player
        } else {
            error("Couldn't find player object.")
        }

        for object in created {
            object.didSetup()
        }
        
    }
    
    func inputCandidates() -> [CommandOwner] {
        var candidates: [CommandOwner] = []
        
        if let location = LocationBehaviour(player.location) {
            candidates.append(contentsOf: location.inputCandidates)
        }

        candidates.append(self)
        
        return candidates
    }
    
    func deliver(_ event: Event, to object: Object) -> Bool {
        eventChannel.log("\(object) received \(event)")

        if object.handle(event) {
            eventChannel.log("\(object) swallowed \(event)")
            return true
        }
        
        if object.observers.count > 0 {
            let nonPropogatingEvent = event.nonPropogating
            for observer in object.observers {
                observerChannel.log("delivered to \(observer) \(nonPropogatingEvent)")
                _ = deliver(nonPropogatingEvent, to: observer)
            }
        }
        
        if event.propogates, let parent = object.location {
            return deliver(event, to: parent)
        }
        
        return false
    }
    
    func handleInput() {
        let input = driver.getInput()
        let candidates = inputCandidates()
        for object in candidates {
            let context = CommandContext(input: input, target: object, engine: self)
            for command in object.commands {
                if command.matches(context) {
                    command.perform(in: context)
                    return
                }
            }
        }
        
        output("I don't know how to \(input.raw)!")
    }

    
    func handleEvents() {
        let events: [Event]
        if self.events.count == 0 {
            events = [Event(id: "idle", target: player, propogates: true)]
        } else {
            events = self.events
            self.events = []
        }
        
        for event in events {
            _ = deliver(event, to: event.target)
        }
    }
    
    func handleSpeech() {
        for response in speech {
            output(response.line)
            for action in response.actions {
                action.perform(with: self)
            }
        }
        speech = []
    }
    
    public func run() {
        setupObjects()

        while running {
            handleEvents()
            handleSpeech()
            handleInput()
            tick += 1
        }
        
        output("Bye.")
    }
    
}

extension Engine: CommandOwner {
    var commands: [Command] {
        return [
            QuitCommand(),
            RestoreCommand(),
            SaveCommand(),
        ]
    }
    
    var names: [String] { [] }
}
