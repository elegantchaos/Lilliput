// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Lilliput
import LilliputExamples

let args = CommandLine.arguments
guard args.count > 1 else {
    fatalError("Usage: \(args[0]) <game> {<commands>}")
}

let driver = BasicDriver()
let engine = Engine(driver: driver)
let game = args[1]
if let url = LilliputExamples.urlForGame(named: game) {
    engine.load(url: url)
    if let url = LilliputExamples.script(named: args.count > 2 ? args[2] : game) {
        engine.readScript(from: url)
    }
    engine.run()
}
