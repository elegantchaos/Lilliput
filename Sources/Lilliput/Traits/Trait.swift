// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol Trait {
    static var id: String { get }
    static var commands: [Command] { get }

    init(with object: Object)
    func didSetup(_ object: Object)
    func handle(_ event: Event) -> Bool
}

extension Trait {
    static var commands: [Command] { [] }

    func didSetup(_ object: Object) {
    }
    
    func handle(_ event: Event) -> Bool {
        return false
    }
    
    var commands: [Command] { Self.commands }
}
