// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import LilliputExamples
import XCTest
import XCTestExtensions

@testable import Lilliput

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

final class LilliputTests: XCTestCase {

    func testSitting() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ChairTest")!
        engine.load(url: url)
        
        driver.input = ["sit chair", "take box", "stand", "sit", "north"]
        engine.run()
        driver.finish()
        
        let expected = ["You are in a shabby looking room.\n\n You can see a box, a chair.\n\nThere is a single exit north.", "\n\n", "You sit on the chair.", "\n\n", "You are sitting on a sturdy looking chair. It\'s not very comfortable. From the chair you can see a shabby looking room.\n\n\n\n It contains a box.\n\nThere is a single exit north.", "\n\n", "You take the box.", "\n\n", "You stand up.", "\n\n", "You are in a shabby looking room.\n\n You can see a chair.\n\nThere is a single exit north.", "\n\n", "You sit on the chair.", "\n\n", "You are sitting on a sturdy looking chair. It\'s not very comfortable. From the chair you can see a shabby looking room.\n\n\n\nThere is a single exit north.", "\n\n", "You are in room 2.\n\nThere is a single exit south to room 1.", "\n\n", "Bye.", "\n\n"]
        XCTAssertEqual(driver.output, expected)
    }

    func testRestore() {
        func save() -> [String] {
            let driver = TestDriver()
            let engine = Engine(driver: driver)
            let url = LilliputExamples.urlForGame(named: "RestoreTest")!
            engine.load(url: url)
            
            driver.input = ["take box", "n", "save unittest1"]
            engine.run()
            driver.finish()

            return driver.output
        }
        
        func restore() -> [String] {
            let driver = TestDriver()
            let engine = Engine(driver: driver)
            let url = LilliputExamples.urlForGame(named: "RestoreTest")!
            engine.load(url: url)
            
            driver.input = ["restore unittest1", "i", "s"]
            engine.run()
            driver.finish()

            return driver.output
        }

        let expected = ["You are in room 1.\n\n You can see a box, a chair, Norman Percival.\n\nThere is a single exit north.", "\n\n", "You take the box.", "\n\n", "You are in room 2.\n\nThere is a single exit south to room 1.", "\n\n", "Bye.", "\n\n"]
        
        XCTAssertEqual(save(), expected)
        
        let expected2 = ["You are in room 1.\n\n You can see a box, a chair, Norman Percival.\n\nThere is a single exit north.", "\n\n", "You are in room 2.\n\nThere is a single exit south to room 1.", "\n\n", "You are carrying a box.", "\n\n", "You are in room 1.\n\n You can see a chair, Norman Percival.\n\nThere is a single exit north to room 2.", "\n\n", "Bye.", "\n\n"]


        XCTAssertEqual(restore(), expected2)
    }
}
