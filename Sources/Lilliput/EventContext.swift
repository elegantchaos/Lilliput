// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct EventContext {
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

