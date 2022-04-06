// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class PushCommand: TargetedCommand {
    init() {
        super.init(keywords: ["push", "shove", "move"])
    }
 
    override func perform(in context: CommandContext) {
        if let output = context.target.getText(for: .push) {
            context.engine.output(output)
            if let action = context.target.getProperty(withKey: "push-action") as? [String:Any] {
                if let target = action[asString: "of"], let property = action[asString: "set"], let value = action["to"] {
                    if let object = context.engine.objects[target] {
                        object.setProperty(withKey: property, to: value)
                    }
                }
            }
        }
    }
}
