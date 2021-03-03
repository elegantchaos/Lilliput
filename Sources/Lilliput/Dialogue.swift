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
        let when: String
        let data: [String:Any]
        
        func value(_ value: Any?, matches expected: Any?) -> Bool {
            if (value == nil) && (expected is NSNull) {
                return true
            }

            if let s1 = value as? String, let s2 = expected as? String {
                return s1 == s2
            }
            
            return false
        }
        
        func valueToTest(in context: Context) -> Any? {
            if when == "playerArrived" {
                let wasPlayerArrived = (context.event.id == "contentAdded") && context.subject.isPlayer
                return wasPlayerArrived
            } else if when == "event" {
                return context.event.id
            } else if let id = data["of"] as? String {
                let of = context.subject.engine.objects[id]
                return of?.getProperty(withKey: when)
            } else {
                return nil
            }
        }
        
        func matches(_ context: Context) -> Bool {
            let actual = valueToTest(in: context)
            if let expected = data["is"] {
                return value(actual, matches: expected)
            } else if let expected = data["not"] {
                return !value(actual, matches: expected)
            } else if let bool = actual as? Bool {
                return bool
            } else {
                context.event.target.engine.warning("Missing test condition for \(actual) in test \(data)")
            }

            return false
        }
        
        init(data: [String:Any]) {
            self.data = data
            self.when = data[stringWithKey: "when"] ?? ""
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
            guard let data = data else {
                print("Sentence \(id) has no data.")
                return nil
            }
            
            guard let lines = data["lines"] as? [String] else {
                print("Sentence \(id) has no lines.")
                return nil
            }

            let triggers = (data["shows"] as? [[String:Any]]) ?? []
            let actions = (data["actions"] as? [[String:Any]]) ?? []

            self.id = id
            self.lines = lines
            self.triggers = triggers.map({ Trigger(data: $0) })
            self.actions = actions.map({ Action(data: $0) })
            self.repeatInterval = 0
        }
        
        func matches(_ context: Context) -> Bool {
            if (repeatInterval == 0) && context.speaker.property(withKey: "spoken", contains: id) {
                print("\(id) already spoken")
                return false
            }
            
            for trigger in triggers {
                if !trigger.matches(context) {
                    print("\(id) failed trigger \(trigger)")
                    return false
                }
            }
            
            print("\(id) matches")
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
