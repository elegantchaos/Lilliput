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
        guard id == .flagChangedEvent else { return false }
        return self[stringWithKey: .flagParameter] == .openedFlag
    }
}

struct OpenableBehaviour: Behaviour {
    static var id: String { "openable" }
    static var commands: [Command] {
        [
            OpenCommand(),
            CloseCommand()
        ]
    }

    let object: Object
    
    init(_ object: Object, storage: Any) {
        self.object = object
    }
    
    static func storage(for object: Object) -> Any {
        return ()
    }
    
    func handle(_ event: Event) -> EventResult {
        if event.isOpenedEvent {
            let output = event.target.getContentsIfVisible()
            if !output.isEmpty {
                event.target.engine.output(output)
            }
            return .handled
        }
        
        return .unhandled
    }

    var isContentVisible: Bool {
        return object.hasFlag(.openedFlag)
    }

}
