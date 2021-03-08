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
            if let string = readLine(), let input = Input(string) {
                return input
            }
        }
    }
    
    public func output(_ string: String) {
        let columns = 80
        
        print("")
        let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            var words = line.split(separator: " ")
            var buffer = ""
            while words.count > 0 {
                let word = words[0]
                words.remove(at: 0)
                if buffer.count + word.count > columns {
                    print(buffer)
                    buffer = ""
                }
                if buffer.count > 0 {
                    buffer += " "
                }

                buffer += word
            }
            print(buffer)
        }
    }
}
