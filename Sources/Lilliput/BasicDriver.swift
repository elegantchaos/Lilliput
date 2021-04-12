// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class BasicDriver: Driver {
    var preamble: [String] = []

    public init() {
    }
    
    public func pushInput(_ string: String) {
        let lines = string.split(separator: "\n").map({ String($0) })
        preamble.append(contentsOf: lines)
    }
    
    public func getInput(stopWords: [String.SubSequence]) -> Input {
        while true {
            if let line = preamble.first, let input = Input(line, stopWords: stopWords) {
                print("\n> \(line)")
                preamble.remove(at: 0)
                return input
            }
            
            print("\n> ", terminator: "")
            if let string = readLine(), let input = Input(string, stopWords: stopWords) {
                return input
            }
        }
    }
    
    public func output(_ string: String, newParagraph: Bool) {
        let columns = 80
        
        if newParagraph {
            print("")
        }
        
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
