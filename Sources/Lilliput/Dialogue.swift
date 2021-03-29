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

        internal init(speaker: Object, subject: Object, event: Event, sentence: Dialogue.Sentence? = nil) {
            self.speaker = speaker
            self.subject = subject
            self.event = event
            self.engine = speaker.engine
        }
    }

    struct Reply {
        let id: String
        let text: String
        let triggers: Triggers

        init?(id: String, data: [String:Any]?) {
            guard let data = data, let text = data[asString: "text"] else {
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
            
            return replies.filter({ $0.matches(context) }).sorted(by: \.id)
        }
    }
    
    struct Sentence {
        let id: String
        let lines: [String]
        let repeatInterval: Int
        
        init?(id: String, data: Any?) {
            self.id = id


            if let line = data as? String {
                self.lines = [line]
                self.repeatInterval = 1
            } else {
                guard let data = data as? [String:Any] else {
                    dialogChannel.log("Sentence \(id) has no data.")
                    return nil
                }
                
                guard let lines = data["lines"] else {
                    dialogChannel.log("Sentence \(id) has no lines.")
                    return nil
                }

                if let lines = lines as? [String] {
                    self.lines = lines
                } else {
                    dialogChannel.log("Lines are wrong format: \(lines)")
                    return nil
                }
                    
                self.repeatInterval = (data["repeatInterval"] as? Int) ?? 1
            }
        }
        
        func matches(_ context: Context) -> Bool {
            if (repeatInterval == 0) && context.speaker.property(withKey: "spoken", contains: id) {
                dialogChannel.log("\(id) already spoken")
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
            sentences = defs.compactMap({ Sentence(id: $0.key, data: $0.value) })
        } else {
            sentences = []
        }
        
        if let defs = object.definition.dialogue?["replies"] as? [String:Any] {
            replies = defs.compactMap({ Reply(id: $0.key, data: $0.value as? [String:Any]) })
        } else {
            replies = []
        }
    }
    
    func sentence(withID id: String) -> Sentence? {
        for sentence in sentences {
            if sentence.id == id {
                return sentence
            }
        }
        return nil
    }
    
    func selectSentence(forContext context: Context) -> Sentence? {
        let options = sentences.filter({ $0.matches(context) })
        let sentence = options.randomElement()
        return sentence
    }

    func speak(inContext context: Context) -> Speech? {
        guard let sentence = selectSentence(forContext: context) else { return nil }
        context.speaker.append(sentence.id, toPropertyWithKey: "spoken")
        context.speaker.setProperty(withKey: "speaking", to: sentence.id)
        return Speech(sentence: sentence, replies: replies, context: context)
    }
}
