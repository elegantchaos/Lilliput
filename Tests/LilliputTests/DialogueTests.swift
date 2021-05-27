// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/05/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import LilliputExamples
import XCTest
import XCTestExtensions

@testable import Lilliput

final class DialogueTests: XCTestCase {
    func testConversationStartStop() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "PersonTest")!
        engine.load(url: url)

        if let url = LilliputExamples.script(named: "dialogTest1") {
            engine.readScript(from: url)
        }

        engine.run()
        driver.finish()

        let expected = ["""
            You are in room 2.
            
            There is a single exit south.
            """
        ]
        XCTAssertEqual(driver.output, expected)
    }

}
