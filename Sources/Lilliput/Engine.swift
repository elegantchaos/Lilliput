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
        let sentence: Dialogue.Sentence
        let target: Object
        
        init?(sentence: Dialogue.Sentence?, target: Object) {
            guard let sentence = sentence else { return nil }
            self.sentence = sentence
            self.target = target
        }
        
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
            DrinkableBehaviour.self,
            FillableBehaviour.self,
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
        let folder = ProjectFolder(url: url)
        do {
            try folder.load(into: self)
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
    
    public func output(_ component: TextComponent, type: OutputType = .normal) {
        driver.output(component.text, type: type)
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
    
    func handleResponse(input: Input, responses: [Response]) -> Bool {
        guard responses.count > 0, let index = Int(input.raw) else { return false }
        
        if index > 0, index <= responses.count {
            let response = responses[index - 1]
            response.sentence.speak(as: player, to: response.target, engine: self, asReply: true)
        } else {
            output("There is no response \(index).", type: .normal)
        }
        
        return true
    }
    
    func handleInput(responses: [Response]) {
        let input = driver.getInput(stopWords: stopWords)
        output(input.raw, type: .rawInput)
        output(input.cleaned, type: .input)
            
        if !handleResponse(input: input, responses: responses) {
            let candidates = inputCandidates()
            var matches: [Command.Match] = []
            for object in candidates {
                for command in object.commands {
                    let context = CommandContext(input: input, target: object, engine: self, candidates: candidates)
                    if command.matches(context) {
                        matches.append(Command.Match(command: command, context: context))
                    }
                }
            }

            if matches.count == 0 {
                output("That didn't really help.")
            } else {
                var performed = false
                for match in matches.sorted() {
                    if !performed || match.kind != .fallback {
                        let matchedContext = CommandContext(match: match, from: matches, candidates: candidates)
                        match.command.perform(in: matchedContext)
                        if match.kind == .exclusive {
                            return
                        } else {
                            performed = true
                        }
                    }
                }
            }
        }
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
            if let dialogue = person.definition.dialogue {
                let replies = dialogue.replies(for: player, to: person)
                responses.append(contentsOf: replies.compactMap { Response(sentence: dialogue.sentence(withID: $0.id), target: person)})
            }
        }

        return responses
    }
    
    func showResponses(_ responses: [Response]) {
        output("Enter a number to respond, or a normal command:", type: .prompt)
        for n in 0 ..< responses.count  {
            let response = responses[n]
            output("\(n + 1). \(response.sentence.text)", type: .response)
        }
    }
    
    func checkConversations() {
        let currentSpeakers = speakers
        for speaker in currentSpeakers {
            speaker.checkConversations()
        }
    }
    
    public func setup() {
        setupObjects()
    }
    
    public func run() {
        setupObjects()

        while running {
            handleEvents()
            checkConversations()
            
            if events.isEmpty && (handlersRan == 0) {
                let responses = getResponses()
                if !responses.isEmpty {
                    showResponses(responses)
                }

                handleInput(responses: responses)
            }
            
            tick += 1
            
            #if DEBUG
            Logger.defaultManager.flush()
            #endif
        }
        
        output("Bye.")
    }
    
    public func object(withID id: String) -> Object {
        return objects[id]!
    }
    
    public var editableObjects: [Object] {
        return objects.values.sorted(by: \.id.localizedLowercase)
    }
    
    /// Return a pseudo-random string from the alternatives stored under a key in a string table.
    /// The same string will be returned each time until the engine tick changes.
    public func string(withKey key: String, from table: StringTable) -> String? {
        guard let alternatives = table.alternatives(for: key) else { return nil }
        return string(fromAlternatives: alternatives)
    }
    
    /// Returns a pseudo-random string from a set of alternatives.
    /// The same string will be returned each time until the engine tick changes.
    public func string(fromAlternatives alternatives: StringAlternatives) -> String {
        let strings = alternatives.strings
        let index = tick % strings.count
        return strings[index]
    }
}

extension Engine: CommandOwner {
    var owningObject: Object? { return nil }

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
