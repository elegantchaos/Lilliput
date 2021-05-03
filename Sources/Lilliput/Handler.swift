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

            if let expectedString = expected as? String {
                if let object = of as? Object {
                    return object.id == expectedString
                }
                
                if let string = of as? String {
                    return string == expectedString
                }

            }
            
            return false
        }
        
        func testPlayerArrived(in context: Context, from: Object?) -> Bool {
            guard context.event.is(.contentAdded) else { return false }
            guard (context.event.target == context.receiver) || (context.event.target == context.receiver.location) else { return false }
            
            guard let arrival = context.event[objectWithKey: .objectParameter] else { return false }
            guard arrival.isPlayer else { return false }

            if let from = from, context.event[objectWithKey: .fromParameter] != from {
                return false
            }
            
            return true
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
        
        func testProperty(key: String, of owner: String, in context: Context) -> Bool {
            let value: Any?
            if owner == "event" {
                value = context.event[rawWithKey: key]
            } else {
                guard let of = context.receiver.engine.objects[owner] else { return false }
                value = of.getProperty(withKey: key)
            }
            
            return testValue(value, in: context)
        }

        func testOr(triggers: [Handler.Trigger], in context: Context) -> Bool {
            for trigger in triggers {
                if trigger.matches(context) {
                    return true
                }
            }
            
            return false
        }

        func testAnd(triggers: [Handler.Trigger], in context: Context) -> Bool {
            for trigger in triggers {
                if !trigger.matches(context) {
                    return false
                }
            }
            
            return true
        }
        
        func matches(_ context: Context) -> Bool {
            if when == "playerArrived" {
                let from = data[asString: .fromParameter].flatMap { context.receiver.engine.objects[$0] }
                return testPlayerArrived(in: context, from: from)
            } else if when == "reply" {
                return testReply(in: context)
            } else if when == "asked" {
                return testAsked(in: context)
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

    struct Action {
        let data: [String:Any]
        
        init(data: [String:Any]) {
            self.data = data
        }
        
        func run(in context: Context) {
            if let output = data[asString: "output"] {
                handleOutput(output, in: context)
            } else if let target = data[asString: "move"] {
                handleMove(target: target, in: context)
            } else if let dialog = data[asString: "speak"] {
                handleSpeak(dialog, in: context)
            } else if let key = data[asString: "set"], let value = data["to"], let id = data[asString: "of"], let object = context.engine.objects[id] {
                object.setProperty(withKey: key, to: value)
            }

            
        }
        
        func handleOutput(_ output: String, in context: Context) {
            context.engine.output(output)
        }
        
        func handleMove(target targetName: String, in context: Context) {
            let target: Object?
            let locationName: String

            if let destination = data[asString: "to"] {
                // we were supplied a target and a destination
                target = context.engine.objects[targetName]
                locationName = destination
            } else {
                // we were just supplied a destination
                // so the target defaults to the player
                target = context.player
                locationName = targetName
            }
            
            guard let location = context.engine.objects[locationName] else {
                context.engine.warning("Missing location for move command: \(locationName)")
                return
            }
            
            guard let object = target else {
                context.engine.warning("Missing target for move command: \(targetName)")
                return
            }
            
            if let inVehicle = data[asBool: "inVehicle"], inVehicle, let vehicle = object.location {
                vehicle.move(to: location)
                object.move(to: location)
            } else {
                object.move(to: location, quiet: true)
            }

        }
        
        func handleSpeak(_ text: String, in context: Context) {
            context.engine.dialogue.append((context, text))
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
