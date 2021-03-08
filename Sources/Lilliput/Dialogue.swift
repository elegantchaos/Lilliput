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
        let speaker: Object
        let subject: Object
        let event: Event
    }

    struct Action {
        let data: [String:Any]
        
        func perform(with engine: Engine) {
            if let key = data[stringWithKey: "set"], let value = data["to"], let id = data[stringWithKey: "of"], let object = engine.objects[id] {
                object.setProperty(withKey: key, to: value)
            }
        }
    }
    
    struct Output {
        let line: String
        let actions: [Action]
        
        init(_ line: String, actions: [Action]) {
            self.line = line
            self.actions = actions
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
            self.repeatInterval = (data["repeatInterval"] as? Int) ?? 0
        }
        
        func matches(_ context: Context) -> Bool {
            if (repeatInterval == 0) && context.speaker.property(withKey: "spoken", contains: id) {
                dialogChannel.log("\(id) already spoken")
                return false
            }
            
            if !triggers.matches(context) {
                dialogChannel.log("\(id) failed triggers")
                return false
            }
            
            dialogChannel.log("\(id) matches")
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
    
    func speak(inContext context: Context) -> Output? {
        guard let sentence = selectSentence(forContext: context) else { return nil }
        
        context.speaker.append(sentence.id, toPropertyWithKey: "spoken")
        return Output(sentence.output, actions: sentence.actions)
    }
}
