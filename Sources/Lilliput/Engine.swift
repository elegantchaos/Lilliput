// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Files
import Foundation
import Logger

let eventChannel = Channel("Events")

extension String {
    static let gameFileExtension = "json"
}

extension Engine.SaveData {
    mutating func setUnlessEmpty(_ value: Self, forKey key: String) {
        if value.count > 0 {
            self[key] = value
        }
    }
}

public class Engine {
    typealias SaveData = [String:Any]
    
    let driver: Driver
    var running = true
    var definitions: [String:Definition] = [:]
    var objects: [String:Object] = [:]
    var player: Object!
    var events: [Event] = []
    var behaviours: [String:Behaviour.Type] = [:]
    
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

    func save(to name: String) {
        let saves = ThrowingManager.folder(for: URL(fileURLWithPath: "Saves"))
        try? saves.create()

        let file = saves.file(ItemName(name, pathExtension: .gameFileExtension))
        
        var dump: SaveData = [:]
        for object in objects {
            dump.setUnlessEmpty(object.value.saveData, forKey: object.key)
        }

        do {
            let json = try JSONSerialization.data(withJSONObject: dump, options: [.prettyPrinted, .sortedKeys])
            file.write(asData: json)
        } catch {
            warning("Failed to save \(name).\n\(error)")
        }
    }
    
    func restore(from name: String) {
        
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
        
        if let location = LocationBehaviour(player.location) {
            candidates.append(contentsOf: location.inputCandidates)
        }

        candidates.append(self)
        
        return candidates
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
    
    func deliver(_ event: Event, to object: Object) -> Bool {
        eventChannel.log("\(object) received \(event)")

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
    
    func register<T>(_ behaviour: T.Type) where T: Behaviour {
        behaviours[behaviour.id] = behaviour
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
