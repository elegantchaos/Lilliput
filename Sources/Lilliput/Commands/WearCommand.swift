//
//  File.swift
//  
//
//  Created by Sam Developer on 01/03/2021.
//

import Foundation

class WearCommand: TargetedCommand {
    init() {
        super.init(keywords: ["wear"])
    }
    
    override func perform(in context: CommandContext) {
        let object = context.target
        let brief = object.getDefinite()
        let output: String
        if context.target.position == .worn {
            output = "You are already wearing \(brief)."
        } else {
            output = "You put on \(brief)."
            object.move(to: context.player, position: .worn)
        }

        context.engine.output(output)

    }
}
