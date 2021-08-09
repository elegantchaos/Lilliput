// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/08/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

class SwearFallbackCommand: GenerateEventCommand {
    let swearySwears = [
        "arse", "arsehole",
        "bastard", "bitch", "bloody", "bollocks", "bugger", "bullshit",
        "cock", "crap", "cunt",
        "dick", "dickhead",
        "fuck", "fucker",
        "motherfucker",
        "prick", "piss",
        "shit",
        "tits", "twat",
        "wank"
    ]
    
    init() {
        super.init(context: .swear, eventID: .swore, keywords: swearySwears)
    }

    override func matches(_ context: CommandContext) -> Bool {
        let words = Set(context.input.raw.split(separator: " ").map { String($0) })
        for swear in swearySwears {
            if words.contains(swear) {
                return true
            }
        }
        
        return false
    }

    override func kind(in context: CommandContext) -> Command.Match.Kind {
        return .fallback
    }
}
