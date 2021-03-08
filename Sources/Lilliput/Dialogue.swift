// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation
import Logger

let dialogChannel = Channel("Dialogue")

struct Dialogue {
    struct Context {
        let engine: Engine
        let speaker: Object
        let subject: Object
        let event: Event
        let sentence: Sentence?

        internal init(speaker: Object, subject: Object, event: Event, sentence: Dialogue.Sentence? = nil) {
            self.speaker = speaker
            self.subject = subject
            self.event = event
            self.engine = speaker.engine
            self.sentence = sentence
        }
        
        func context(for sentence: Sentence) -> Context {
            assert(self.sentence == nil)
            return Context(speaker: speaker, subject: subject, event: event, sentence: sentence)
        }
    }

    struct Action {
        let data: [String:Any]
        
        func perform(with engine: Engine) {
            if let key = data[stringWithKey: "set"], let value = data["to"], let id = data[stringWithKey: "of"], let object = engine.objects[id] {
                object.setProperty(withKey: key, to: value)
            }
        }
    }
    
    struct Reply {
        let id: String
        let text: String
        let triggers: Triggers

        init?(id: String, data: [String:Any]?) {
            guard let data = data, let text = data["text"] as? String else {
                dialogChannel.log("Reply \(id) missing data.")
                return nil
            }
            
            self.id = id
            self.text = text
            self.triggers = Triggers(from: data["shows"])
        }
        
        func matches(_ context: Context) -> Bool {
            if context.subject.property(withKey: "repliedRecently", contains: id) {
                return false
            }
            
            if !triggers.matches(context) {
                dialogChannel.log("reply \(id) failed triggers")
                return false
            }
            
            dialogChannel.log("reply \(id) matches")
            return true
        }
        
    }
    
    struct Speech {
        let sentence: Sentence
        let replies: [Reply]
        let context: Dialogue.Context
        
        func speak() -> [Reply] {
            let engine = context.engine
            engine.output(sentence.output)
            for action in sentence.actions {
                action.perform(with: engine)
            }
            
            return replies.filter({ $0.matches(context) }).sorted(by: \.id)
        }
    }
    
    struct Sentence {
        let id: String
        let lines: [String]
        let triggers: Triggers
        let actions: [Action]
        let repeatInterval: Int
        
        init?(id: String, data: [String:Any]?) {
            guard let data = data else {
                dialogChannel.log("Sentence \(id) has no data.")
                return nil
            }
            
            guard let lines = data["lines"] as? [String] else {
                dialogChannel.log("Sentence \(id) has no lines.")
                return nil
            }

            let actions = (data["actions"] as? [[String:Any]]) ?? []

            self.id = id
            self.lines = lines
            self.triggers = Triggers(from: data["shows"])
            self.actions = actions.map({ Action(data: $0) })
            self.repeatInterval = (data["repeatInterval"] as? Int) ?? 1
        }
        
        func matches(_ context: Context) -> Bool {
            if (repeatInterval == 0) && context.speaker.property(withKey: "spoken", contains: id) {
                dialogChannel.log("\(id) already spoken")
                return false
            }
            
            if !triggers.matches(context) {
                dialogChannel.log("sentence \(id) failed triggers")
                return false
            }
            
            dialogChannel.log("sentence \(id) matches")
            return true
        }

        var output: String {
            return lines.randomElement() ?? "<missing lines>"
        }
    }

    let sentences: [Sentence]
    let replies: [Reply]
    
    init(for object: Object) {
        if let defs = object.definition.dialogue?["sentences"] as? [String:Any] {
            sentences = defs.compactMap({ Sentence(id: $0.key, data: $0.value as? [String:Any]) })
        } else {
            sentences = []
        }
        
        if let defs = object.definition.dialogue?["replies"] as? [String:Any] {
            replies = defs.compactMap({ Reply(id: $0.key, data: $0.value as? [String:Any]) })
        } else {
            replies = []
        }
    }
    
    func selectSentence(forContext context: Context) -> Sentence? {
        let options = sentences.filter({ $0.matches(context) })
        let sentence = options.randomElement()
        return sentence
    }
    
    func selectReplies(forSentence sentence: Sentence, inContext context: Context) -> [Reply] {
        let replies = replies.filter({ $0.matches(context.context(for: sentence)) })
        return replies
    }

    func speak(inContext context: Context) -> Speech? {
        guard let sentence = selectSentence(forContext: context) else { return nil }
        context.speaker.append(sentence.id, toPropertyWithKey: "spoken")
        return Speech(sentence: sentence, replies: replies, context: context.context(for: sentence))
    }
}
