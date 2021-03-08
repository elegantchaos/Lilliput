// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct Triggers {
    let triggers: [Trigger]
    
    init(from data: Any?) {
        let records = (data as? [[String:Any]]) ?? []
        triggers = records.map({ Trigger(data: $0) })
    }
    
    func matches(_ context: Dialogue.Context) -> Bool {
        for trigger in triggers {
            if !trigger.matches(context) {
                dialogChannel.log("failed trigger \(trigger)")
                return false
            }
        }
        return true
    }
}
