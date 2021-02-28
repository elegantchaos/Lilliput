// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Engine {
    let driver: Driver
    
    public init(driver: Driver) {
        self.driver = driver
    }
    
    public func load(name: String) {
        
    }
    
    public func run() {
        var running = true
        
        while running {
            let input = driver.getInput()
            switch input.command {
                case "quit", "q":
                    running = false
                    
                default:
                    print(input)
            }
        }
    }
}
