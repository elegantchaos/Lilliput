// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Handlers {
    
    let handlers: [Handler]
    
    init(from definitions: Any?) {
        if let definitions = definitions as? [[String:Any]] {
            handlers = definitions.compactMap({ Handler($0) })
        } else {
            handlers = []
        }
    }
    
    func process(_ event: Event, receiver: Object) {
        let context = Handler.Context(event: event, receiver: receiver)
        for handler in handlers {
            if handler.matches(context: context) {
                handler.run(in: context)
            }
        }
    }
}

struct Handler {
    struct Context {
        let event: Event
        let receiver: Object
        let engine: Engine
        let player: Object
        
        init(event: Event, receiver: Object) {
            self.event = event
            self.receiver = receiver
            self.player = receiver.engine.player
            self.engine = receiver.engine
        }
    }

    struct Trigger {
        let when: String
        let data: [String:Any]
        
        func testMatch(of: Any?, with expected: Any?) -> Bool {
            if (of == nil) && (expected is NSNull) {
                return true
            }

            if let s1 = of as? String, let s2 = expected as? String {
                return s1 == s2
            }
            
            return false
        }
        
        func testPlayerArrived(in context: Context) -> Bool {
            guard context.event.is(.contentAdded) else { return false }
            guard context.event.target == context.receiver.location else { return false }
            guard let arrival = context.event[objectWithKey: .objectParameter] else { return false }

            return arrival.isPlayer
        }
        
        func testReply(in context: Context) -> Bool {
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
        
//        func testSentence(in context: Context) -> Bool {
//            if let id = data[asString: "was"] {
//                return context.sentence?.id == id
//            } else if let id = data[asString: "not"] {
//                return context.sentence?.id != id
//            } else if let ids = data[asString: "in"], let sentenceID = context.sentence?.id {
//                return ids.contains(sentenceID)
//            } else {
//                return false
//            }
//        }
        
        func testAsked(in context: Context) -> Bool {
            if let ids = data["includes"] as? [String] {
                let recent = context.player.getStrings(withKey: "repliedRecently")
                return Set(ids).intersection(recent).count > 0
            }

            return false
        }
        
        
        func testValue(_ actual: Any?, in context: Context) -> Bool {
            if let expected = data["is"] {
                return testMatch(of: actual, with: expected)
            } else if let expected = data["not"] {
                return !testMatch(of: actual, with: expected)
            } else {
                context.event.target.engine.warning("Missing test condition for \(String(describing: actual)) in test \(data)")
                return false
            }
        }
        
        func matches(_ context: Context) -> Bool {
            if when == "playerArrived" {
                return testPlayerArrived(in: context)
            } else if when == "reply" {
                return testReply(in: context)
            } else if when == "asked" {
                return testAsked(in: context)
//            } else if when == "sentence" {
//                return testSentence(in: context)
            } else if when == "event" {
                return testValue(context.event.id, in: context)
            } else if let id = data[asString: "of"] {
                guard let of = context.receiver.engine.objects[id] else { return false }
                let value = of.getProperty(withKey: when)
                return testValue(value, in: context)
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

    struct Action {
        let data: [String:Any]
        
        init(data: [String:Any]) {
            self.data = data
        }
        
        func run(in context: Context) {
            if let output = data[asString: "output"] {
                context.engine.output(output)
            } else if let location = data[asString: "move"] {
                if let location = context.engine.objects[location] {
                    context.player.move(to: location)
                }
            } else if let dialog = data[asString: "speak"] {
                context.engine.dialogue.append((context, dialog))
            } else if let key = data[asString: "set"], let value = data["to"], let id = data[asString: "of"], let object = context.engine.objects[id] {
                object.setProperty(withKey: key, to: value)
            }

            
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
    
    func matches(context: Context) -> Bool {
        for trigger in triggers {
            if !trigger.matches(context) {
                return false
            }
        }
            
        return true
    }
    
    func run(in context: Context) {
        for action in actions {
            action.run(in: context)
        }
    }
}
