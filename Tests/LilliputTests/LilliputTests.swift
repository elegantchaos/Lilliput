// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Examples
import Lilliput
import XCTest
import XCTestExtensions

@testable import Lilliput

class TestDriver: Driver {
    
    var input: [String] = []
    var output: [String] = []
    
    func getInput(stopWords: [String.SubSequence]) -> Input {
        guard let string = input.first else { return Input("quit", stopWords: stopWords)! }
        
        input.remove(at: 0)
        output.append("> \(string)")
        return Input(string, stopWords: [])!
    }
    
    func output(_ string: String, newParagraph: Bool) {
        output.append(string)
    }
    
    
}

final class LilliputTests: XCTestCase {
    func testSimple() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = Examples.urlForGame(named: "PersonTest")!
        engine.load(url: url)
        
        driver.input = ["n"]
        engine.run()
        
        let expected = ["You are in room 1.\n\n You can see a box, a chair, Norman Percival.\n\nThere is a single exit north.", "> n", "You are in room 2.\n\nThere is a single exit south to room 1.", "Bye."]
        XCTAssertEqual(driver.output, expected)
    }
    
    func testRestore() {
        func save() -> [String] {
            let driver = TestDriver()
            let engine = Engine(driver: driver)
            let url = Examples.urlForGame(named: "PersonTest")!
            engine.load(url: url)
            
            driver.input = ["take box", "n", "save"]
            engine.run()
            
            print(driver.output)
            return driver.output
        }
        
        func restore() -> [String] {
            let driver = TestDriver()
            let engine = Engine(driver: driver)
            let url = Examples.urlForGame(named: "PersonTest")!
            engine.load(url: url)
            
            driver.input = ["restore", "i", "s"]
            engine.run()
            
            print(driver.output)
            return driver.output
        }

        let expected = ["You are in room 1.\n\n You can see a box, a chair, Norman Percival.\n\nThere is a single exit north.", "> take box", "You take the box.", "> n", "You are in room 2.\n\nThere is a single exit south to room 1.", "> save", "Bye."]
        XCTAssertEqual(save(), expected)
        
        let expected2 = ["You are in room 1.\n\n You can see a box, a chair, Norman Percival.\n\nThere is a single exit north.", "> take box", "You take the box.", "> n", "You are in room 2.\n\nThere is a single exit south to room 1.", "> save", "Bye."]
        XCTAssertEqual(restore(), expected2)
    }
}
