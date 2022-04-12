// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation
import Logger

let handlerChannel = Channel("handler")

public struct Handlers {
    
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
                handlerChannel.log("handler \(handler.triggers) matched")
                handler.run(in: context)
                context.engine.handlersRan += 1
            }
        }
    }
    
    var asInterchange: [[String:Any]] {
        let value = handlers.map({ $0.asInterchange })
        assertEncodable(value)
        return value
    }
}

struct Handler {
    struct Trigger {
        let when: String
        let data: [String:Any]
        
        func testContents(of: Any?, includes: Any?) -> Bool {
            if let list = of as? [String], let value = includes as? String {
                return list.contains(value)
            }
            
            if let record = of as? [String:Int] {
                let values: [String]
                if let string = includes as? String {
                    values = [string]
                } else if let list = includes as? [String] {
                    values = list
                } else {
                    values = []
                }
                
                for value in values {
                    if record[value] != nil {
                        return true
                    }
                }
            }

            return false
        }
        
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
               
        func testLocation(_ location: Any?, containsObject object: Any?, in context: EventContext) -> Bool {
            guard let locationID = location as? String, let location = context.engine.objects[locationID] else { return false }
            guard let objectID = object as? String, let object = context.engine.objects[objectID] else { return false }
            return location.contains(object)
        }
        
        func testValue(_ actual: Any?, in context: EventContext) -> Bool {
            if let expected = data["is"] {
                return testMatch(of: actual, with: expected)
            } else if let expected = data["not"] {
                return !testMatch(of: actual, with: expected)
            } else if let expected = data["contains"] {
                return testContents(of: actual, includes: expected)
            } else if let expected = data["containsObject"] {
                return testLocation(actual, containsObject: expected, in: context)
            } else if let expected = data["doesntContainObject"] {
                return !testLocation(actual, containsObject: expected, in: context)
            } else {
                context.event.target.engine.warning("Missing test condition for \(String(describing: actual)) in test \(data)")
                return false
            }
        }
        
        func testProperty(key: String, of owner: String, in context: EventContext) -> Bool {
            let value: Any?
            if owner == "event" {
                value = context.event[rawWithKey: key]
            } else if owner == "target" {
                value = context.event.target.getProperty(withKey: key)
            } else if owner == "receiver" {
                value = context.receiver.getProperty(withKey: key)
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
        
        var asInterchange: [String: Any] {
            var value = data
            value[nonEmpty: "when"] = when
            
            assertEncodable(value)
            return value
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
            handlerChannel.log("handler ran \(action) in \(context)")
            action.run(in: context)
        }
    }
    
    var asInterchange: [String:Any] {
        var value: [String:Any] = [:]
        value[nonEmpty: "actions"] = actions.map({ $0.asInterchange })
        value[nonEmpty: "triggers"] = triggers.map({ $0.asInterchange })
        
        assertEncodable(value)
        return value
    }
}

func assertEncodable<T>(_ value: T) {
    #if DEBUG
    do {
        _ = try JSONSerialization.data(withJSONObject: value)
    } catch {
        fatalError("Can't encode \(value)")
    }
    #endif
}
