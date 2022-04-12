// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import LilliputExamples
import XCTest
import XCTestExtensions

@testable import Lilliput

final class LilliputTests: XCTestCase {
    func testSitting() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ChairTest")!
        engine.load(url: url)
        
        driver.input = ["sit chair"]
        engine.run()
        driver.finish()
        
        XCTAssertEqual(engine.player.location?.id, "Chair")
    }

    func testOpening() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "OpenTest")!
        engine.load(url: url)


        driver.input = ["open desk"]
        driver.checks[0] = { _ in
            let desk = engine.objects["Your Desk"]!
            XCTAssertFalse(desk.hasFlag("open"))
        }
        
        engine.run()
        driver.finish()

        let desk = engine.objects["Your Desk"]!
        XCTAssertTrue(desk.hasFlag("open"))

    }
}
