// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct PersonBehaviour: Behaviour {
    static var id: String { "person" }
    static var commands: [Command] {
        [
            TalkCommand()
        ]
    }

    let object: Object
    
    init(_ object: Object, storage: Any) {
        self.object = object
    }
    
    static func storage(for object: Object) -> Void {
    }
    
    func handle(_ event: Event) -> EventResult {
        var result = EventResult.unhandled
        switch EventID(rawValue: event.id) {
            case .moved:
                if event.target == object {
                    if let location = event[objectWithKey: .fromParameter] {
                        location.remove(observer: object)
                        result = .handled
                    }
                    
                    if let location = event[objectWithKey: .toParameter] {
                        location.add(observer: object)
                        result = .handled
                    }
                }
                

            default:
                break
        }

        return result
        
    }
    
//    func performActions(inContext context: EventContext) {
//        let engine = object.engine
//        if let output = dialogue.speak(inContext: context) {
//            engine.spoken.append(output)
//        }
//    }
}
