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
            try? normalised.write(to: outputFile(named: "\(name)-expected", extension: "json"))
            try? encoded.write(to: outputFile(named: "\(name)-actual", extension: "json"))
        }
        print(actual)
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
}
