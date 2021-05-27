// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Lilliput
import LilliputExamples

let driver = BasicDriver()
let engine = Engine(driver: driver)
let url = LilliputExamples.urlForGame(named: "PersonTest")!
engine.load(url: url)

if CommandLine.arguments.count > 1 {
    let script = CommandLine.arguments[1]
    if let url = LilliputExamples.script(named: script), FileManager.default.fileExists(atURL: url) {
        engine.readScript(from: url)
    }
}


engine.run()
