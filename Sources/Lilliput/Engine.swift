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
    struct ReplySelection {
        let id: String
        let text: String
        let speaker: Object
    }
    
    let driver: Driver
    var running = true
    var definitions: [String:Definition] = [:]
    var objects: [String:Object] = [:]
    var player: Object!
    var events: [Event] = []
    var behaviours: [String:Behaviour.Type] = [:]
    var dialogue: [(Handler.Context,String)] = []
    var spoken: [Dialogue.Speech] = []
    var replies: [ReplySelection] = []
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
            MovableBehaviour.self,
            OpenableBehaviour.self,
            PersonBehaviour.self,
            PlayableBehaviour.self,
            PlayerBehaviour.self,
            PushableBehaviour.self,
            PortalBehaviour.self,
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
                driver.error("\(error)")
        }
            
    }

    public func readScript(from url: URL) {
        if let text = ThrowingManager.file(for: url).asText {
            driver.pushInput(text)
        }
    }
    
    public func output(_ string: String, newParagraph: Bool = true) {
        driver.output(string, newParagraph: newParagraph)
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
    
    func deliver(_ event: Event, to object: Object) -> EventResult {
        eventChannel.log("\(object) received \(event)")

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
    
    func handleInput() {
        let input = driver.getInput(stopWords: stopWords)
        
        if input.arguments.count == 0, let index = Int(input.command), index > 0, index <= replies.count {
            let reply = replies[index - 1]
            post(event: Event(.replied, target: reply.speaker, parameters: [ .replyIDParameter : reply.id ]))
            output("“\(reply.text)”")
            player.append(reply.id, toPropertyWithKey: "replied")
            player.append(reply.id, toPropertyWithKey: "repliedRecently")
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
        for (context,sentenceID) in dialogue {
            if let person = PersonBehaviour(context.receiver) {
                let dialog = person.dialogue
                if let sentence = dialog.sentence(withID: sentenceID) {
                    handle(sentence: sentence, person: person, event: context.event)
                }
            }
        }
        
        if replies.count > 0 {
            output("(type a number to respond, or a normal command to end the conversation)")
        }
    }
    
    func handle(sentence: Dialogue.Sentence, person: PersonBehaviour, event: Event) {
        person.object.append(sentence.id, toPropertyWithKey: "spoken")
        person.object.setProperty(withKey: "speaking", to: sentence.id)
        let speech = Dialogue.Speech(sentence: sentence, replies: person.dialogue.replies, context: Dialogue.Context(speaker: person.object, subject: player, event: event))

        for reply in speech.speak() {
            let n = replies.count + 1
            output("\(n). \(reply.text)", newParagraph: n == 1)
            replies.append(ReplySelection(id: reply.id, text: reply.text, speaker: speech.context.speaker))
        }

    }
    
    func clearSpeech() {
        dialogue = []
        spoken = []
        replies = []
    }
    
    public func run() {
        setupObjects()

        while running {
            handleEvents()
            handleSpeech()
            
            // handling events or speech may have generated more events...
            // we only stop for input when we've handled them all
            if events.count == 0 {
                handleInput()
            }
            
            clearSpeech()
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
