// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Coercion
import Foundation

extension String {
    static let openedFlag = "open"
    static let openAction = "open"
    static let closeAction = "close"
}

extension Event {
    var isOpenedEvent: Bool {
        guard event.id == .flagChangedEvent else { return false }
        return event.parameters[stringWithKey: .flagParameter] == .openedFlag
    }
}

struct OpenableTrait: Trait {
    static var id: String { "openable" }

    static var commands: [Command] {
        [
            OpenCommand(),
            CloseCommand()
        ]
    }
    
    init(with object: Object) {
    }
    
    func handle(_ event: Event) -> Bool {
        if event.isOpenedEvent {
            event.target.showContentsIfVisible()
        }
        
        return false
    }
}

extension Object {
    var isContentVisible: Bool {
        if let _ = aspect(OpenableTrait.self) {
            return hasFlag(.openedFlag)
        } else {
            return true
        }
    }
}
