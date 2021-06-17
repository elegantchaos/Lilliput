// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Lilliput
import XCTest
import XCTestExtensions

class TestDriver: Driver {
    
    let showOutput = false
    var input: [String] = []
    var count = 0
    var output: [String] = []
    var full: [String] = []
    var checks: [Int:(String) -> Void] = [:]
    var lastType: OutputType?
    
    func pushInput(_ string: String) {
        let lines = string.split(separator: "\n").map({ String($0) })
        input.append(contentsOf: lines)
    }
    
    func getInput(stopWords: [String.SubSequence]) -> Input {
        
        guard let string = input.first else { return Input("quit", stopWords: stopWords)! }

        checks[count]?(string)
        count += 1

        input.remove(at: 0)
        if (lastType == .response) {
            full.append("")
        }

        full.append("> \(string)\n")
        return Input(string, stopWords: [])!
    }
    
    func output(_ string: String, type: OutputType) {
        switch type {
            case .error:
                print(string)
                XCTFail("Engine threw error: \(string)")

            case .input, .rawInput:
                break

            default:
                append(string)
                
                if (type != .append) && (type != .response) {
                    append("")
                }
        }

        lastType = type
    }
    
    func append(_ string: String) {
        output.append(string)
        full.append(string)
    }
    
    func finish() {
        checks[count]?("")
        if showOutput {
            print(output)
            print(full.joined())
        }
    }
    
}
