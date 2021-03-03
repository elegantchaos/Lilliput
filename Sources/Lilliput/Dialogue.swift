// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 03/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Dialog {
    struct Context {
        let speaker: Object
        let subject: Object
        let event: Event
    }

    struct Trigger {
        let data: [String:Any]
        
        func matches(_ context: Context) -> Bool {
            return true
        }
    }
    
    struct Action {
        let data: [String:Any]
    }
    
    struct Output {
        let line: String
        let actions: [Action]
        
        init(_ line: String, actions: [Action]) {
            self.line = line
            self.actions = actions
        }
    }
    
    struct Sentence {
        let id: String
        let lines: [String]
        let triggers: [Trigger]
        let actions: [Action]
        let repeatInterval: Int
        
        init?(id: String, data: [String:Any]?) {
            guard
                let lines = data?["lines"] as? [String],
                let triggers = data?["shows"] as? [[String:Any]],
                let actions = data?["actions"] as? [[String:Any]]
            else {
                return nil
            }

            self.id = id
            self.lines = lines
            self.triggers = triggers.map({ Trigger(data: $0) })
            self.actions = actions.map({ Action(data: $0) })
            self.repeatInterval = 0
        }
        
        func matches(_ context: Context) -> Bool {
            if (repeatInterval == 0) && context.speaker.property(withKey: "spoken", contains: id) {
                return false
            }
            
            for trigger in triggers {
                if !trigger.matches(context) {
                    return false
                }
            }
            
            return true
        }

        var output: String {
            return lines.randomElement() ?? "<missing lines>"
        }
    }

    let sentences: [Sentence]
    
    init(for object: Object) {
        if let dialogue = object.definition.properties["dialogue"] as? [String:Any] {
            sentences = dialogue.compactMap({ Sentence(id: $0.key, data: $0.value as? [String:Any]) })
        } else {
            sentences = []
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
