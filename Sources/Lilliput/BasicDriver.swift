// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct BasicDriver: Driver {
    public init() {
        
    }
    
    public func getInput() -> Input {
        while true {
            print("\n> ", terminator: "")
            if let string = readLine() {
                let words = string.split(separator: " ")
                if words.count > 0 {
                    let command = String(words[0])
                    let args = words.dropFirst().map({ String($0) })
                    return Input(raw: string, command: command, arguments: args)

                }
                
            }
        }
    }
    
    public func output(_ string: String) {
        print("\n\(string)")
    }
}
