// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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
    
    func testPlayerArrived(in context: Dialogue.Context) -> Bool {
        let wasPlayerArrived = (context.event.id == "contentAdded") && context.subject.isPlayer
        let inOurLocation = (context.event.target == context.speaker.location)
        return wasPlayerArrived && inOurLocation
    }
    
    func testReply(in context: Dialogue.Context) -> Bool {
        if context.event.id == EventId.replied.rawValue {
            let replyID = context.event[stringWithKey: .replyIDParameter]
            if let id = data["was"] as? String {
                return replyID == id
            } else if let id = data["not"] as? String {
                return replyID != id
                
            }
        }
         
        return false
    }
    
    func testSentence(in context: Dialogue.Context) -> Bool {
        if let id = data["was"] as? String {
            return context.sentence?.id == id
        } else if let id = data["not"] as? String {
            return context.sentence?.id != id
        } else {
            return false
        }
    }
    
    func testValue(_ actual: Any?, in context: Dialogue.Context) -> Bool {
        if let expected = data["is"] {
            return testMatch(of: actual, with: expected)
        } else if let expected = data["not"] {
            return !testMatch(of: actual, with: expected)
        } else {
            context.event.target.engine.warning("Missing test condition for \(String(describing: actual)) in test \(data)")
            return false
        }
    }
    
    func matches(_ context: Dialogue.Context) -> Bool {
        if when == "playerArrived" {
            return testPlayerArrived(in: context)
        } else if when == "reply" {
            return testReply(in: context)
        } else if when == "sentence" {
            return testSentence(in: context)
        } else if when == "event" {
            return testValue(context.event.id, in: context)
        } else if let id = data["of"] as? String {
            guard let of = context.subject.engine.objects[id] else { return false }
            let value = of.getProperty(withKey: when)
            return testValue(value, in: context)
        } else {
            context.event.target.engine.warning("Missing match type for \(self) in \(data)")

        }
        
        return false
    }
    
    init(data: [String:Any]) {
        self.data = data
        self.when = data[stringWithKey: "when"] ?? ""
    }
}
