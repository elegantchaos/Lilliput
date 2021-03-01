// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol Trait {
    init(with object: Object)
    static var id: String { get }
    static var commands: [Command] { get }
    func handle(_ event: Event) -> Bool
}

extension Trait {
    static var commands: [Command] { [] }
    func handle(_ event: Event) -> Bool {
        return false
    }
    
    var commands: [Command] { Self.commands }
}
