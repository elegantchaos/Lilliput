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
        super.init(flag: .openedFlag, state: true, mode: .openAction, keywords: ["open"])
    }
    
    override func requirementsAreSatisfied(in context: CommandContext) -> Bool {
        return !context.target.hasFlag(.lockedFlag)
    }
    
    override func defaultReport(forKey key: String, in context: CommandContext) -> String {
        let object = context.target
        if object.hasFlag(.lockedFlag) {
            let brief = object.getDefinite()
           return "\(brief.capitalizedFirst) is locked."
        } else {
            return super.defaultReport(forKey: key, in: context)
        }
    }
}

class CloseCommand: ChangeFlagCommand {
    init() {
        super.init(flag: .openedFlag, state: false, mode: .closeAction, keywords: ["close"])
    }
}

