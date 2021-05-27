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

        if let url = LilliputExamples.script(named: "DialogTest1") {
            engine.readScript(from: url)
        }

        driver.checks[1] = { output in XCTAssertEqual(engine.speakers.count, 0) }
        driver.checks[3] = { output in XCTAssertEqual(engine.speakers.count, 2) }

        engine.run()
        driver.finish()
        
        print(driver.full.joined(separator: "\n"))
        
        XCTAssertEqual(engine.speakers.count, 0)
    }

}
