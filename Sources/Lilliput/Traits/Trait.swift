// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol Behaviour {
    static var id: String { get }
    static var commands: [Command] { get }

    var object: Object { get }

    static func data(for object: Object) -> Any
    init(_ object: Object, data: Any)
    func didSetup()
    func handle(_ event: Event) -> Bool
}

extension Behaviour {
    static var commands: [Command] { [] }

    static func data(for object: Object) -> Any {
        return ()
    }
    
    func didSetup() {
    }
    
    func handle(_ event: Event) -> Bool {
        return false
    }
    
    var commands: [Command] { Self.commands }
    
    init?(_ object: Object?) {
        guard let object = object else { return nil }
        guard let data = object.traits[Self.id] else { return nil }
        self.init(object, data: data)
    }
}
