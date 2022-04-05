// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import LilliputExamples
import XCTest
import XCTestExtensions

@testable import Lilliput

final class DescriptionTests: XCTestCase {
    func testInventory() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ContainersTest")!
        engine.load(url: url)
        engine.setupObjects()
        
        let player = engine.player!
        let behaviour = PlayerBehaviour(player)!

        let ball = engine.object(withID: "Ball")
        ball.move(to: player)

        let inventory = behaviour.describeInventory().text
        XCTAssertEqual(inventory, "You are carrying a ball. You are wearing a long greatcoat.")
        
        let coat = engine.object(withID: "Coat")
        coat.move(to: player.location!)

        let box = engine.object(withID: "Box")
        box.move(to: player)
        
        let inventory2 = behaviour.describeInventory().text
        XCTAssertEqual(inventory2, "You are carrying a ball and a large box.")
    }
    
    func testBox() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ContainersTest")!
        engine.load(url: url)
        engine.setupObjects()
        
        let box = engine.object(withID: "Box")
        XCTAssertEqual(box.getDescriptionAndContents(), "A large box with a latch on the lid. The box is currently closed.")

        box.setFlag(.openedFlag)
        XCTAssertEqual(box.getDescriptionAndContents(), "A large box with a latch on the lid. It is currently open.")

        let ball = engine.object(withID: "Ball")
        ball.move(to: box)
        box.clearFlag(.openedFlag)

        XCTAssertEqual(box.getDescriptionAndContents(), "A large box with a latch on the lid. The box is currently closed.")
        
        box.setFlag(.openedFlag)

        XCTAssertEqual(box.getDescriptionAndContents(), "A large box with a latch on the lid. It is currently open. The box contains a ball.")
    }

    func testTable() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ContainersTest")!
        engine.load(url: url)
        engine.setupObjects()
        
        let table = engine.object(withID: "Table")
        let ball = engine.object(withID: "Ball")
        ball.move(to: table, position: .on)
        
        let description = table.getDescriptionAndContents()
        XCTAssertEqual(description, "A flat table. On it is a ball.")
    }

}
