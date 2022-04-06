// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let flagChangedEvent = "flagChanged"
    static let flagParameter = "flag"
    static let stateParameter = "state"
}

class ChangeFlagCommand: TargetedCommand {
    let flag: String
    let state: Bool
    let mode: String

    init(flag: String, state: Bool, mode: String, keywords: [String]) {
        self.flag = flag
        self.state = state
        self.mode = mode
        super.init(keywords: keywords)
    }
    
    func requirementsAreSatisfied(in context: CommandContext) -> Bool {
        return true
    }
    
    func defaultReport(forKey key: String, in context: CommandContext) -> String {
        let brief = context.target.getDefinite()
        switch key {
            case "already":
                return "\(brief.capitalizedFirst) is already \(mode)ed."
                
            case "missing": return "You are missing something."

            case "changed":
                let custom = context.target.getText(for: "\(mode)")
                return custom ?? "You \(mode) \(brief)."
                
            default:
                return "\(key): \(context.target.getDefinite())"
        }
    }
    
    func outputReport(forKey key: String, in context: CommandContext) {
        let object = context.target
        let output: String
        if let custom = object.getText(for: "\(flag)-\(key)-\(state)") {
            output = custom
        } else {
            output = defaultReport(forKey: key, in: context)
        }
        
        context.engine.output(output)
    }
    
    override func perform(in context: CommandContext) {
        let object = context.target
        if object.hasFlag(flag) == state {
            outputReport(forKey: "already", in: context)
        } else if !requirementsAreSatisfied(in: context) {
            outputReport(forKey: "missing", in: context)
        } else {
            object.setProperty(withKey: flag, to: state)
            context.engine.post(event: Event(id: .flagChangedEvent, target: object, parameters: [.flagParameter: flag, .stateParameter: state]))
            outputReport(forKey: "changed", in: context)
        }
    }
}
