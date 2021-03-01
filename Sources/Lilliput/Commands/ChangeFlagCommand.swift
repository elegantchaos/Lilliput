// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class ChangeFlagCommand: TargetedCommand {
    let flag: String
    let state: Bool
    
    init(flag: String, state: Bool, keywords: [String]) {
        self.flag = flag
        self.state = state
        super.init(keywords: keywords)
    }
    
    func requirementsAreSatisfied(in context: Context) -> Bool {
        return true
    }
    
    func defaultReport(forKey key: String, in context: Context) -> String {
        return "\(key): \(context.target.getDefinite())"
    }
    
    func outputReport(forKey key: String, in context: Context) {
        let object = context.target
        if let custom = object.getDescription(for: "\(flag)-\(key)-\(state)") {
            context.engine.output(custom)
        }
        
        let description = defaultReport(forKey: key, in: context)
        context.engine.output(description)
    }
    
    override func perform(in context: Context) {
        if !requirementsAreSatisfied(in: context) {
            outputReport(forKey: "missing", in: context)
        } else if context.target.hasFlag(flag) == state {
            outputReport(forKey: "already", in: context)
        } else {
            context.target.setProperty(withKey: flag, to: state)
            outputReport(forKey: "changed", in: context)
        }
    }
}
