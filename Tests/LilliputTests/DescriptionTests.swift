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
    func testLocationDescription() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ContainersTest")!
        engine.load(url: url)
        engine.setupObjects()
        
        let player = engine.player!
        let behaviour = PlayerBehaviour(player)!
        let description = behaviour.describeLocation()
        XCTAssertEqual(description, """
            You are in a shabby looking room.
            
            You can see a ball, a large box and a flat table.
            """)
    }

    func testComplexContainers() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "ComplexContainmentTest")!
        engine.load(url: url)
        engine.setupObjects()
        
        let player = engine.player!
        let behaviour = PlayerBehaviour(player)!
        XCTAssertEqual(behaviour.describeLocation(), """
            You are in a shabby looking room.
            
            You can see a large box and a flat table.
            """)
        
        let table = engine.object(withID: "Table")
        XCTAssertEqual(table.describeWithContents(), "A flat table. On it is a ball. Under the table is a bin.")

    }

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
        XCTAssertEqual(box.describeWithContents(), "A large box with a latch on the lid. The box is currently closed.")

        box.setFlag(.openedFlag)
        XCTAssertEqual(box.describeWithContents(), "A large box with a latch on the lid. It is currently open.")

        let ball = engine.object(withID: "Ball")
        ball.move(to: box)
        box.clearFlag(.openedFlag)

        XCTAssertEqual(box.describeWithContents(), "A large box with a latch on the lid. The box is currently closed.")
        
        box.setFlag(.openedFlag)

        XCTAssertEqual(box.describeWithContents(), "A large box with a latch on the lid. It is currently open. The box contains a ball.")
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
        
        let description = table.describeWithContents()
        XCTAssertEqual(description, "A flat table. On it is a ball.")
    }

    func testLockablePortal() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "PortalTest")!
        engine.load(url: url)
        engine.setupObjects()

        let door = engine.object(withID: "Room 1 Door")
        XCTAssertEqual(door.describe(context: .detailed), "A normal office door, with a keyhole. The door is locked.")
        
        door.clearFlag(.lockedFlag)

        XCTAssertEqual(door.describe(context: .detailed), "A normal office door, with a keyhole. The door is unlocked.")
    }
    
    func testExits() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "PortalTest")!
        engine.load(url: url)
        engine.setupObjects()

        let room = engine.object(withID: "Room 1")
        let behaviour = LocationBehaviour(room)!
        XCTAssertEqual(behaviour.describeExits(), "There are exits north through a door and south.")
        
        let destination = engine.object(withID: "Room 2")
        destination.setFlag(.awareFlag)

        XCTAssertEqual(behaviour.describeExits(), "There are exits north through a door to room 2 and south.")
    }

    func testSingleExit() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: "PortalTest")!
        engine.load(url: url)
        engine.setupObjects()

        let room = engine.object(withID: "Room 3")
        let behaviour = LocationBehaviour(room)!
        XCTAssertEqual(behaviour.describeExits(), "There is a single exit north.")

        let destination = engine.object(withID: "Room 1")
        destination.setFlag(.awareFlag)

        XCTAssertEqual(behaviour.describeExits(), "There is a single exit north to room 1.")
    }

}
