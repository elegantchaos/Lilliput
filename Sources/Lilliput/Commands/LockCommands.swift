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

    override func defaultReport(forKey key: String, in context: Context) -> String {
        let brief = context.target.getDefinite()
        switch key {
            case "already": return "\(brief) is already locked."
            case "changed": return "You lock \(brief)."
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


class UnlockCommand: ChangeFlagCommand {
    init() {
        super.init(flag: .lockedFlag, state: false, keywords: ["unlock"])
    }

    override func defaultReport(forKey key: String, in context: Context) -> String {
        let brief = context.target.getDefinite()
        switch key {
            case "already": return "\(brief) is already unlocked."
            case "changed": return "You unlock \(brief)."
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

