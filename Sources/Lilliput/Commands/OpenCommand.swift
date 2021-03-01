// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class OpenCloseCommand: ChangeFlagCommand {
    
    init(state: Bool, keywords: [String]) {
        let mode = state ? "lock" : "unlock"
        super.init(flag: .lockedFlag, state: state, mode: mode, keywords: keywords)
    }
}

class OpenCommand: ChangeFlagCommand {
    init() {
        super.init(flag: .openedFlag, state: true, mode: "open", keywords: ["open"])
    }
}

class CloseCommand: ChangeFlagCommand {
    init() {
        super.init(flag: .openedFlag, state: false, mode: "close", keywords: ["close"])
    }
}

