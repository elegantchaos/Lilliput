// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation
import Logger

let dialogChannel = Channel("Dialogue")

struct Dialogue {
    struct Reply {
        let id: String
        let index: Int
        let text: String
        let trigger: Handler.Trigger

        init?(data: [String:Any]?, index: Int) {
            guard let data = data, let id = data[asString: "id"] else {
                dialogChannel.log("Reply \(index) missing data / id.")
                return nil
            }
            
            guard let text = data[asString: "text"] else {
                dialogChannel.log("Reply \(id) missing text.")
                return nil
            }
            
            guard let trigger = data["triggers"] as? [String:Any] else {
                dialogChannel.log("Reply \(id) missing trigger.")
                return nil
            }
            
            self.id = id
            self.index = index
            self.text = text
            self.trigger = Handler.Trigger(data: trigger)
        }
        
        func matches(_ context: EventContext) -> Bool {
            if context.player.property(withKey: .spokenKey, contains: id) {
                return false
            }
            
            if !trigger.matches(context) {
                dialogChannel.log("reply \(id) failed triggers")
                return false
            }
            
            dialogChannel.log("reply \(id) matches")
            return true
        }
        
    }
    
    struct Sentence {
        fileprivate let id: String
        fileprivate let lines: [String]
        fileprivate let repeatInterval: Int
        
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

        func speak(as speaker: Object, engine: Engine) {
            if !speaker.property(withKey: .spokenKey, contains: id) {
                let text = lines.randomElement() ?? "<missing lines>"
                engine.output(text)
                speaker.append(id, toPropertyWithKey: .spokenKey)
                speaker.setProperty(withKey: .speakingKey, to: id)
                engine.post(event: Event(.said, target: speaker, parameters: [.spokenKey: id]))
            }
        }
    }

    let sentences: [String:Sentence]
    let replies: [Reply]
    let triggers: [String:Any]

    init?(from data: [String:Any]?) {
        guard let defs = data?["sentences"] as? [String:Any] else { return nil }
        
        var sentences: [String:Sentence] = [:]
        for def in defs {
            if let sentence = Sentence(id: def.key, data: def.value) {
                sentences[sentence.id] = sentence
            }
        }
        self.sentences = sentences
        
        if let defs = data?["replies"] as? [[String:Any]] {
            var index = 0
            replies = defs.compactMap({
                let reply = Reply(data: $0, index: index)
                index = index + 1
                return reply
            })
        } else {
            replies = []
        }
        
        self.triggers = (data?["triggers"] as? [String:Any]) ?? [:]
    }
    
    func sentence(withID id: String) -> Sentence? {
        sentences[id]
    }
    
    /// Returns a set of handlers generated from the triggers.
    /// The action for these handlers is always to speak a one of the sentences.
    var handlers: [Handler] {
        var handlers: [Handler] = []
        for (sentence, trigger) in triggers {
            var triggers = trigger as? [Any]
            if triggers == nil, let trigger = trigger as? [String:Any] {
                triggers = [trigger]
            }
            
            if let triggers = triggers {
                let handler: [String:Any] = [
                    "actions": [["speak" : sentence]],
                    "triggers": triggers
                ]
                
                if let handler = Handler(handler) {
                    handlers.append(handler)
                }
            }
        }

        return handlers
    }
    
    func replies(for speaker: Object, to person: Object) -> [Reply] {
        let event = Event(.getReplies, target: person)
        let context = EventContext(event: event, receiver: speaker)
        return replies.filter({ $0.matches(context) }).sorted(by: \.id)
    }
}
