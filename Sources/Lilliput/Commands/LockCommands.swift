// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let lockedFlag = "locked"
}

extension String {
    var capitalizedFirst: String {
        var items = self.split(separator: " ")
        if items.count > 0 {
            items[0] = String.SubSequence(items[0].capitalized)
        }
        return items.joined(separator: " ")
    }
}

class LockUnlockCommand: ChangeFlagCommand {
    let mode: String
    
    init(state: Bool, keywords: [String]) {
        mode = state ? "lock" : "unlock"
        super.init(flag: .lockedFlag, state: state, keywords: keywords)
    }

    override func defaultReport(forKey key: String, in context: Context) -> String {
        let brief = context.target.getDefinite()
        switch key {
            case "already": return "\(brief.capitalizedFirst) is already \(mode)ed."
            case "changed": return "You \(mode) \(brief)."
            case "missing":
                let lockable = context.target.aspect(LockableTrait.self)
                if let lockable = lockable, let object = lockable.requiredObject {
                    return "You need \(object.getIndefinite())."
                } else {
                    return "You need a key."
                }
                
            default:
                return super.defaultReport(forKey: key, in: context)
        }
    }

    override func requirementsAreSatisfied(in context: Context) -> Bool {
        guard let lockable = context.target.aspect(LockableTrait.self) else { return false }
        
        return lockable.requiredObject?.isCarriedByPlayer ?? true
    }
}

class LockCommand: LockUnlockCommand {
    init() {
        super.init(state: true, keywords: ["lock"])
    }
}

class UnlockCommand: LockUnlockCommand {
    init() {
        super.init(state: false, keywords: ["unlock"])
    }
}

