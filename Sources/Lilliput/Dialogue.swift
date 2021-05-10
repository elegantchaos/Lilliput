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
        let triggers: ReplyTriggers

        init?(data: [String:Any]?, index: Int) {
            guard let data = data, let id = data[asString: "id"] else {
                dialogChannel.log("Reply \(index) missing data / id.")
                return nil
            }
            
            guard let text = data[asString: "text"] else {
                dialogChannel.log("Reply \(id) missing text.")
                return nil
            }
            
            self.id = id
            self.index = index
            self.text = text
            self.triggers = ReplyTriggers(from: data["shows"])
        }
        
        func matches(_ context: EventContext) -> Bool {
            if context.player.property(withKey: "repliedRecently", contains: id) {
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
        let context: EventContext
        
        func speak() -> [Reply] {
            let engine = context.engine
            let paragraphs = sentence.output.split(separator: "\n")
            for para in paragraphs {
                engine.output(String(para), type: .dialogue)
            }
            
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
        
        func matches(_ context: EventContext) -> Bool {
            if (repeatInterval == 0) && context.receiver.property(withKey: "spoken", contains: id) {
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
        
        if let defs = object.definition.dialogue?["replies"] as? [[String:Any]] {
            var index = 0
            replies = defs.compactMap({
                let reply = Reply(data: $0, index: index)
                index = index + 1
                return reply
            })
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
    
    func selectSentence(forContext context: EventContext) -> Sentence? {
        let options = sentences.filter({ $0.matches(context) })
        let sentence = options.randomElement()
        return sentence
    }

    func speak(inContext context: EventContext) -> Speech? {
        guard let sentence = selectSentence(forContext: context) else { return nil }
        let speaker = context.event.target
        speaker.append(sentence.id, toPropertyWithKey: "spoken")
        speaker.setProperty(withKey: "speaking", to: sentence.id)
        return Speech(sentence: sentence, replies: replies, context: context)
    }
}
