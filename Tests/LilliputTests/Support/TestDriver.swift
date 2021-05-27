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
    
    func pushInput(_ string: String) {
        let lines = string.split(separator: "\n").map({ String($0) })
        input.append(contentsOf: lines)
    }
    
    func getInput(stopWords: [String.SubSequence]) -> Input {
        
        guard let string = input.first else { return Input("quit", stopWords: stopWords)! }

        checks[count]?(string)
        count += 1

        input.remove(at: 0)
        full.append("> \(string)\n\n")
        return Input(string, stopWords: [])!
    }
    
    func output(_ string: String, type: OutputType) {
        switch type {
            case .input, .rawInput: return
            case .error:
                print(string)
                XCTFail("Engine threw error: \(string)")

            default:
                break
        }
        output.append(string)
        full.append(string)
        if type != .append {
            output.append("\n\n")
            full.append("\n\n")
        }
    }
    
    func finish() {
        checks[count]?("")
        if showOutput {
            print(output)
            print(full.joined())
        }
    }
    
}
