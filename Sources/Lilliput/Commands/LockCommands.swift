// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let lockedFlag = "locked"
}

class LockCommand: ChangeFlagCommand {
    init() {
        super.init(flag: .lockedFlag, state: true, keywords: ["lock"])
    }
}


class UnlockCommand: ChangeFlagCommand {
    init() {
        super.init(flag: .lockedFlag, state: false, keywords: ["unlock"])
    }
}

