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
    
    override func perform(in context: CommandContext) {
        guard let subcommand = arguments.first else {
            return
        }
        
        switch subcommand {
            case "log":
                performLog(in: context)
                
            case "dump":
                performDump(in: context)
                
            case "conversations":
                performConversations(in: context)
                
            default:
                context.engine.output("Unknown debug command: \(subcommand).")
                break
        }
    }
    
    func performLog(in context: CommandContext) {
        let manager = Channel.defaultManager
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
            } else {
                engine.output("Unknown channel \(arguments[1])")
            }
        }
    }

    func performDump(in context: CommandContext) {
        context.player.dump()
        context.player.location?.dump()
    }
    
    func performConversations(in context: CommandContext) {
        let engine = context.engine
        let conversations = engine.speakers.map({ String(describing: $0) })
        if conversations.count == 0 {
            engine.output("No conversations.")
        } else {
            engine.output("Speakers: \(conversations.joined(separator: ", "))")
        }
    }
}
