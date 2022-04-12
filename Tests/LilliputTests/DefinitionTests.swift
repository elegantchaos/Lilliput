// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import LilliputExamples
import XCTest
import XCTestExtensions

@testable import Lilliput

final class DefinitionTests: XCTestCase {
    func testRoundTrip(for name: String) throws {
        let url = LilliputExamples.urlForDefinition(named: name)!
        try testRoundTrip(url: url)
    }
    
    func testRoundTrip(url: URL) throws {
        let json = try Data(contentsOf: url)
        let decoded = try JSONSerialization.jsonObject(with: json)
        let normalised = try JSONSerialization.data(withJSONObject: decoded, options: [.prettyPrinted, .sortedKeys])
        let definition = Definition(id: "room1", properties: decoded as! [String:Any])
        let exported = definition.asInterchange
        let encoded = try JSONSerialization.data(withJSONObject: exported, options: [.prettyPrinted, .sortedKeys])
        let expected = String(data: normalised, encoding: .utf8)!
        let actual = String(data: encoded, encoding: .utf8)!
        XCTAssertEqual(actual, expected)
        if actual != expected {
            let name = url.lastPathComponent
            try? normalised.write(to: outputFile(named: "\(name)-expected", extension: "json"))
            try? encoded.write(to: outputFile(named: "\(name)-actual", extension: "json"))
        }
    }

    func testRoundTrip(game name: String) throws {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let url = LilliputExamples.urlForGame(named: name)!
        let converted = engine.convert(url: url, into: outputDirectory().appendingPathComponent("Converted").appendingPathComponent(name))
        for definition in converted {
            try testRoundTrip(url: definition)
        }
    }
    

    func testRoom2() throws {
        try testRoundTrip(for: "room1")
        try testRoundTrip(for: "room2")
    }
    
    func testPerson() throws {
        try testRoundTrip(for: "person")
    }
    
    func testObjects() throws {
        try testRoundTrip(for: "chair")
    }
    
    func testRoundtripGames() throws {
        try testRoundTrip(game: "ChairTest")
        try testRoundTrip(game: "ComplexContainmentTest")
        try testRoundTrip(game: "ContainersTest")
        try testRoundTrip(game: "OpenTest")
        try testRoundTrip(game: "PersonTest")
        try testRoundTrip(game: "PortalTest")
        try testRoundTrip(game: "WeightTest")
    }
}
