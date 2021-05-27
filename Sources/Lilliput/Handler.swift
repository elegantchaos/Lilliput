// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation

struct Handlers {
    
    let handlers: [Handler]
    
    init(from definitions: Any?, dialogue: Dialogue?) {
        if let definitions = definitions as? [[String:Any]] {
            var handlers = definitions.compactMap({ Handler($0) })
            if let dialogueHandlers = dialogue?.handlers {
                handlers.append(contentsOf: dialogueHandlers)
            }

            self.handlers = handlers
        } else {
            self.handlers = []
        }
    }
    
    func process(in context: EventContext) {
        for handler in handlers {
            if handler.matches(context: context) {
//                print("handler \(handler.triggers) matched")
                handler.run(in: context)
                context.engine.handlersRan += 1
            }
        }
    }
}

struct Handler {
    struct Trigger {
        let when: String
        let data: [String:Any]
        
        func testMatch(of: Any?, with expected: Any?) -> Bool {
            if (of == nil) && (expected is NSNull) {
                return true
            }

            if let expectedString = expected as? String {
                if let object = of as? Object {
                    return object.id == expectedString
                }
                
                if let value = of as? StringConvertible {
                    return value.asString == expectedString
                }
            }
            
            if let expectedBool = expected as? Bool {
                if let value = of as? BoolConvertible {
                    return value.asBool == expectedBool
                }
            }
            
            return false
        }
        
        func testPlayerArrived(in context: EventContext, from: Object?) -> Bool {
            guard context.event.is(.contentAdded) else { return false }
            guard (context.event.target == context.receiver) || (context.event.target == context.receiver.location) else { return false }
            
            guard let arrival = context.event[objectWithKey: .objectParameter] else { return false }
            guard arrival.isPlayer else { return false }

            if let from = from, context.event[objectWithKey: .fromParameter] != from {
                return false
            }
            
            return true
        }
        
        func testReply(in context: EventContext) -> Bool {
            if context.event.id == EventID.replied.rawValue {
                let replyID = context.event[stringWithKey: .replyIDParameter]
                if let id = data[asString: "was"] {
                    return replyID == id
                } else if let id = data[asString: "not"] {
                    return replyID != id
                    
                }
            }
             
            return false
        }
        
        func testAsked(in context: EventContext) -> Bool {
            if let ids = data["includes"] as? [String] {
                let recent = context.player.getStrings(withKey: "repliedRecently")
                return Set(ids).intersection(recent).count > 0
            }

            return false
        }
        
        func testSentence(in context: EventContext) -> Bool {
            if context.event.id == EventID.said.rawValue {
                let sentenceID = context.event[stringWithKey: "sentence"]
                if let id = data[asString: "was"] {
                    return sentenceID == id
                }
            }
//            let sentence = context.event.target.getString(withKey: "speaking")
//            if let id = data[asString: "was"] {
//                return sentence == id
//            } else if let id = data[asString: "not"] {
//                return sentence != id
//            } else if let ids = data[asString: "in"] {
//                return ids.contains(sentence)
//            } else {
//                return false
//            }
            return false
        }

        func testValue(_ actual: Any?, in context: EventContext) -> Bool {
            if let expected = data["is"] {
                return testMatch(of: actual, with: expected)
            } else if let expected = data["not"] {
                return !testMatch(of: actual, with: expected)
            } else {
                context.event.target.engine.warning("Missing test condition for \(String(describing: actual)) in test \(data)")
                return false
            }
        }
        
        func testProperty(key: String, of owner: String, in context: EventContext) -> Bool {
            let value: Any?
            if owner == "event" {
                value = context.event[rawWithKey: key]
            } else {
                guard let of = context.receiver.engine.objects[owner] else { return false }
                value = of.getProperty(withKey: key)
            }
            
            return testValue(value, in: context)
        }

        func testOr(triggers: [Handler.Trigger], in context: EventContext) -> Bool {
            for trigger in triggers {
                if trigger.matches(context) {
                    return true
                }
            }
            
            return false
        }

        func testAnd(triggers: [Handler.Trigger], in context: EventContext) -> Bool {
            for trigger in triggers {
                if !trigger.matches(context) {
                    return false
                }
            }
            
            return true
        }
        
        func matches(_ context: EventContext) -> Bool {
            if when == "playerArrived" {
                let from = data[asString: .fromParameter].flatMap { context.receiver.engine.objects[$0] }
                return testPlayerArrived(in: context, from: from)
            } else if when == "reply" {
                return testReply(in: context)
            } else if when == "asked" {
                return testAsked(in: context)
            } else if when == "sentence" {
                return testSentence(in: context)
            } else if when == "event" {
                return testValue(context.event.id, in: context)
            } else if when == "any", let of = data["of"] as? [[String:Any]] {
                let triggers = of.map({ Trigger(data: $0) })
                return testOr(triggers: triggers, in: context)
            } else if when == "all", let of = data["of"] as? [[String:Any]] {
                let triggers = of.map({ Trigger(data: $0) })
                return testAnd(triggers: triggers, in: context)
            } else if let owner = data[asString: "of"] {
                return testProperty(key: when, of: owner, in: context)
            } else {
                context.event.target.engine.warning("Missing match type for \(self) in \(data)")

            }
            
            return false
        }
        
        init(data: [String:Any]) {
            self.data = data
            self.when = data[asString: "when"] ?? ""
        }
    }


    let triggers: [Trigger]
    let actions: [Action]
    
    init?(_ definition: [String:Any]) {
        guard
            let actions = definition["actions"] as? [[String:Any]],
            let triggers = definition["triggers"] as? [[String:Any]]
        else {
            return nil
        }

        self.triggers = triggers.map({ Trigger(data: $0) })
        self.actions = actions.map({ Action(data: $0) })
    }
    
    func matches(context: EventContext) -> Bool {
        for trigger in triggers {
            if !trigger.matches(context) {
                return false
            }
        }
            
        return true
    }
    
    func run(in context: EventContext) {
        for action in actions {
//            print("handler ran \(action)")
            action.run(in: context)
        }
    }
}
