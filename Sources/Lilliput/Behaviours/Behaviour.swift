// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

protocol Behaviour {
    typealias ID = String

    static var id: ID { get }
    static var commands: [Command] { get }

    var object: Object { get }
    var saveData: Engine.SaveData { get }
    
    static func storage(for object: Object) -> Any
    init(_ object: Object, storage: Any)

    func didSetup()
    func handle(_ event: Event) -> Bool
    func restore(from data: Engine.SaveData)
}

extension Behaviour {
    static var commands: [Command] { [] }

    static func storage(for object: Object) -> Any {
        return ()
    }

    init?(_ object: Object?) {
        guard let data = object?.behaviourStorage[Self.id] else { return nil }
        self.init(object!, storage: data)
    }

    var id: ID { Self.id }
    var commands: [Command] { Self.commands }
    
    var saveData: Engine.SaveData {
        [:]
    }

    func didSetup() {
    }
    
    func handle(_ event: Event) -> Bool {
        return false
    }
    
    func restore(from data: Engine.SaveData) {
        
    }
}
