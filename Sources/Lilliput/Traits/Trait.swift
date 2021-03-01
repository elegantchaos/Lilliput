// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol Trait {
    static var id: String { get }
    static var commands: [Command] { get }
    static func handle(_ event: Event) -> Bool
}

extension Trait {
    static var commands: [Command] { [] }
    static func handle(_ event: Event) -> Bool {
        return false
    }
}
