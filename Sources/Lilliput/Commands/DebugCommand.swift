// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

class DebugCommand: Command {
    init() {
        super.init(keywords: ["debug"])
    }
    
    override func perform(in context: Context) {
        guard let subcommand = context.input.arguments.first else {
            return
        }
        
        switch subcommand {
            case "log":
                performLog(in: context)
                
            default:
                context.engine.output("Unknown debug command: \(subcommand).")
                break
        }
    }
    
    func performLog(in context: Context) {
        let manager = Channel.defaultManager
        let arguments = context.input.arguments
        let engine = context.engine
        
        if (arguments.count > 1) && (arguments[1] == "list") {
            var output = "Log channels:"
            for channel in manager.registeredChannels {
                output += "\n- \(channel.name)"
            }
            engine.output(output)
            
        } else if arguments.count > 2 {
            if let channel = manager.channel(named: arguments[1]) {
                let state = ["on", "enabled", "true"].contains(arguments[2])
                manager.update(channels: [channel], state: state)
            }
        }
    }
    
}
