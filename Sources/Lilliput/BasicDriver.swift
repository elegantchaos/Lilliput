// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class BasicDriver: Driver {
    var preamble: [String] = []
    var lastType: OutputType = .normal

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
    
    public func output(_ string: String, type: OutputType) {
        

        var separator: String
        switch type {
            case .input, .rawInput: return // no need to echo the input
            
            case .warning: separator = "\nWARNING: "
            case .error: separator = "\nERROR: "
            case .debug: separator = "\nDEBUG: "

            case .normal, .dialogue, .prompt: separator = "\n"
            case .append: separator = ""

            case .option: separator = (lastType == .option) ? "" : "\n"
        }

        let columns = 80
        let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            var words = line.split(separator: " ")
            var buffer: String = ""

            while words.count > 0 {
                let word = words[0]
                words.remove(at: 0)
                if buffer.count + word.count > columns {
                    print(buffer)
                    buffer = ""
                    separator = ""
                }

                buffer += separator
                separator = " "

                buffer += word
            }
            print(buffer)
            separator = ""
        }
        
        lastType = type
    }
}
