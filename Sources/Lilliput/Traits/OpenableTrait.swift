// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let openedFlag = "open"
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
