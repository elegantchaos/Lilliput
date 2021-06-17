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
    static let replyIDParameter = "id"
}

public class Engine {
    struct Response {
        let reply: Dialogue.Reply
        let target: Object
    }
    
    let driver: Driver
    var running = true
    var definitions: [String:Definition] = [:]
    var objects: [String:Object] = [:]
    var player: Object!
    var events: [Event] = []
    var behaviours: [String:Behaviour.Type] = [:]
//    var conversations: [Conversation] = []
    var speakers: Set<Object> = []
    var handlersRan = 0
    var tick = 0
    var stopWords: [String.SubSequence] = []
    
    public init(driver: Driver) {
        self.driver = driver
        registerStandardBehaviours()
    }
    
    public func registerStandardBehaviours() {
        register([
            LocationBehaviour.self,
            LockableBehaviour.self,
            LoadableBehaviour.self,
            MovableBehaviour.self,
            OpenableBehaviour.self,
            PersonBehaviour.self,
            PlayableBehaviour.self,
            PlayerBehaviour.self,
            PushableBehaviour.self,
            PortalBehaviour.self,
            ShootableBehaviour.self,
            SittableBehaviour.self,
            UsableBehaviour.self,
            WearableBehaviour.self
        ])
    }
    
    func register(_ definition: Definition) {
        definitions[definition.id] = definition
        engineChannel.log("registered object \(definition.id)")
    }
    
    func register(_ behaviours: [Behaviour.Type]) {
        for behaviour in behaviours {
            self.behaviours[behaviour.id] = behaviour
            engineChannel.log("registered behaviour \(behaviour.id)")
        }
    }
    
    public func load(url: URL) {
        
        let folder = ThrowingManager.folder(for: url)
        do {
            try folder.forEach { item in
                if item.name.pathExtension == "json", let file = item as? ThrowingFile {
                    let definitions = DefinitionsFile(file: file)
                    try definitions.load(into: self)
                } else if item.name.pathExtension == "stop", let file = item as? ThrowingFile {
                    if let text = file.asText {
                        stopWords = text.split(separator: "\n")
                    }
                }
            }
        } catch {
            driver.output("\(error)", type: .error)
        }
            
    }

    public func readScript(from url: URL) {
        if let text = ThrowingManager.file(for: url).asText {
            driver.pushInput(text)
        }
    }
    
    public func updateSpeakers(toInclude speakers: Set<Object>) {
        self.speakers.formUnion(speakers)
    }
    
    public func updateSpeakers() {
        speakers = speakers.filter({ $0.speakingTo.count > 0 })
    }
    
    public func output(_ string: String, type: OutputType = .normal) {
        driver.output(string, type: type)
    }
    
    public func warning(_ string: String) {
        driver.output(string, type: .warning)
    }
    
    public func error(_ string: String) -> Never {
        driver.output(string, type: .error)
        exit(1)
    }
    
    public func debug(_ string: String) {
        driver.output(string, type: .debug)
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
    
    func resetObjects() {
        let objects = self.objects.values
        for object in objects {
            object.reset()
        }
        
        for object in objects {
            object.setup()
        }
        
        for object in objects {
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
    
    func deliver(_ event: Event, to object: Object) -> EventResult {
        eventChannel.log("\(object) received \(event)")
//        print("\(object) received \(event)")

        var result = object.handle(event)
        if result == .swallowed {
            eventChannel.log("\(object) swallowed \(event)")
            return .swallowed
        }
        
        if object.observers.count > 0 {
            let nonPropogatingEvent = event.nonPropogating
            for observer in object.observers {
                observerChannel.log("delivered to \(observer) \(nonPropogatingEvent)")
                result = result.merged(with: deliver(nonPropogatingEvent, to: observer))
            }
        }
        
        if event.propogates, let parent = object.location {
            result = result.merged(with: deliver(event, to: parent))
        }
        
        return result
    }
    
    func handleInput(responses: [Response]) {
        let input = driver.getInput(stopWords: stopWords)
        output(input.raw, type: .rawInput)
        output(input.cleaned, type: .input)
        
        if let index = Int(input.raw) {
            if index > 0, index <= responses.count {
                let response = responses[index - 1]
                let id = response.reply.id
                let text = response.reply.text
                post(event: Event(.replied, target: response.target, parameters: [ .replyIDParameter : id ]))
                output("“\(text)”", type: .responseChosen)
                player.append(id, toPropertyWithKey: .spokenKey)
                player.setProperty(withKey: .speakingKey, to: id)
            } else {
                output("There is no response \(index).", type: .normal)
            }

            return
        }
        
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
        
        output("That didn't really help.")
    }

    
    func handleEvents() {
        let events: [Event]
        if (self.events.count == 0) && (self.handlersRan == 0) {
            events = [Event(id: "idle", target: player, propogates: true)]
        } else {
            events = self.events
            self.events = []
            self.handlersRan = 0
        }
        
        for event in events {
            _ = deliver(event, to: event.target)
        }
    }

    func getResponses() -> [Response] {
        var responses: [Response] = []
        for person in player.speakingTo {
            if let replies = person.definition.dialogue?.replies(for: player, to: person) {
                responses.append(contentsOf: replies.map { Response(reply: $0, target: person)})
            }
        }

        return responses
    }
    
    func showResponses(_ responses: [Response]) {
        output("Enter a number to respond, or a normal command:", type: .prompt)
        for n in 0 ..< responses.count  {
            let response = responses[n]
            output("\(n + 1). \(response.reply.text)", type: .response)
        }
    }
    
    func checkConversations() {
        let currentSpeakers = speakers
        for speaker in currentSpeakers {
            speaker.checkConversations()
        }
    }
    
    public func run() {
        setupObjects()

        while running {
            // process events until there are none left
            while !events.isEmpty {
                tick += 1
                handleEvents()
                checkConversations()
            }
            
            let responses = getResponses()
            if !responses.isEmpty {
                showResponses(responses)
            }

            handleInput(responses: responses)
        }
        
        output("Bye.")
    }
    
}

extension Engine: CommandOwner {
    var commands: [Command] {
        return [
            QuitCommand(),
            ResetCommand(),
            RestoreCommand(),
            SaveCommand(),
        ]
    }
    
    var names: [String] { [] }
}
