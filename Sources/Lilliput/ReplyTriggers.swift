// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct ReplyTriggers {
    let triggers: [Handler.Trigger]

    init(from data: Any?) {
        let records = (data as? [[String:Any]]) ?? []
        triggers = records.map({ Handler.Trigger(data: $0) })
    }
    
    func matches(_ context: EventContext) -> Bool {
        for trigger in triggers {
            if !trigger.matches(context) {
                dialogueChannel.log("failed trigger \(trigger)")
                return false
            }
        }
        return true
    }
}
