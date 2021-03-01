// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class ChangeFlagCommand: TargetedCommand {
    let flag: String
    let state: Bool
    var meetsRequirements: Bool { true }
    var reports: [String:String] = [:]
    
    init(flag: String, state: Bool, keywords: [String]) {
        self.flag = flag
        self.state = state
        super.init(keywords: keywords)
    }
    
    func outputReport(forKey key: String, in context: Context) {
        let object = context.target
        if let custom = object.getDescription(for: "\(flag)\(key)") {
            context.engine.output(custom)
        }
        
        let brief = object.getDefinite()
        let report = reports[key] ?? key
        let description = "\(brief) \(report)"
        context.engine.output(description)
    }
    
    override func perform(in context: Context) {
        if !meetsRequirements {
            outputReport(forKey: "MissingRequirements", in: context)
        } else if context.target.hasFlag(flag) == state {
            outputReport(forKey: "WasAlreadySet", in: context)
        } else {
            context.target.setProperty(withKey: flag, to: state)
            outputReport(forKey: "DidSet", in: context)
        }
    }
}
