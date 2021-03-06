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
    let dialogue: Dialogue
    
    init(_ object: Object, storage: Any) {
        self.object = object
        self.dialogue = storage as! Dialogue
    }
    
    static func storage(for object: Object) -> Any {
        return Dialogue(for: object)
    }
    
    func handle(_ event: Event) -> Bool {
        switch EventId(rawValue: event.id) {
            case .movedFrom:
                if event.target == object, let location = event[objectWithKey: .containerParameter] {
                    location.remove(observer: object)
                }

            case .movedTo:
                if event.target == object, let location = event[objectWithKey: .containerParameter] {
                    location.add(observer: object)
                }
                
            default:
                break
        }

        performActions(inContext: Dialogue.Context(speaker: object, subject: object.engine.player, event: event))

        return false
        
    }
    
    func performActions(inContext context: Dialogue.Context) {
        let engine = object.engine
        if let output = dialogue.speak(inContext: context) {
            engine.spoken.append(output)
        }
    }
}
