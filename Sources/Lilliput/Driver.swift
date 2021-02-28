// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Input {
    let raw: String
    let command: String
    let arguments: [String]

    public init(raw: String, command: String, arguments: [String]) {
        self.raw = raw
        self.command = command
        self.arguments = arguments
    }
}

public protocol Driver {
    func getInput() -> Input
}
