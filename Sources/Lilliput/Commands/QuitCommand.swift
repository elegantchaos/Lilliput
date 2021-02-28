//
//  File.swift
//  
//
//  Created by Sam Developer on 28/02/2021.
//

import Foundation

struct QuitCommand: Command {
    func matches(_ context: Context) -> Bool {
        return context.input.command == "quit"
    }
    
    func perform(in context: Context) {
        context.engine.running = false
    }
}
