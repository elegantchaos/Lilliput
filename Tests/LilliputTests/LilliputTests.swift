// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions
import Lilliput

@testable import Lilliput

class TestDriver: Driver {
    var input: [String] = []
    var output: [String] = []
    
    func getInput() -> Input {
        guard let string = input.first else { return Input("quit")! }
        
        input.remove(at: 0)
        output.append("> \(string)")
        return Input(string)!
    }
    
    func output(_ string: String) {
        output.append(string)
    }
    
    
}

final class LilliputTests: XCTestCase {
    func testExample() {
        let driver = TestDriver()
        let engine = Engine(driver: driver)
        let resourceBundleURL = Bundle(for: Self.self).url(forResource: "Lilliput_LilliputTests", withExtension: "bundle")!
        let resourceBundle = Bundle(url: resourceBundleURL)!
        let url = resourceBundle.url(forResource: "PersonTest", withExtension: nil, subdirectory: "Games")!
        engine.load(url: url)
        
        driver.input = ["n"]
        engine.run()
        print(driver.output)
    }
}
