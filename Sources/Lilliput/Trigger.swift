// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

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
    
    func valueToTest(in context: Dialogue.Context) -> Any? {
        if when == "playerArrived" {
            let wasPlayerArrived = (context.event.id == "contentAdded") && context.subject.isPlayer
            let inOurLocation = (context.event.target == context.speaker.location)
            return wasPlayerArrived && inOurLocation
        } else if when == "reply", let id = data["was"] as? String {
            let wasReply = context.event.id == EventId.replied.rawValue
            return wasReply && context.event[stringWithKey: .replyIDParameter] == id
        } else if when == "event" {
            return context.event.id
        } else if let id = data["of"] as? String {
            let of = context.subject.engine.objects[id]
            return of?.getProperty(withKey: when)
        } else {
            return nil
        }
    }
    
    func matches(_ context: Dialogue.Context) -> Bool {
        let actual = valueToTest(in: context)
        if let expected = data["is"] {
            return value(actual, matches: expected)
        } else if let expected = data["not"] {
            return !value(actual, matches: expected)
        } else if let bool = actual as? Bool {
            return bool
        } else {
            context.event.target.engine.warning("Missing test condition for \(String(describing: actual)) in test \(data)")
        }

        return false
    }
    
    init(data: [String:Any]) {
        self.data = data
        self.when = data[stringWithKey: "when"] ?? ""
    }
}
