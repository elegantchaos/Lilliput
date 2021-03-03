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
    let dialogue: Dialog
    
    init(_ object: Object, storage: Any) {
        self.object = object
        self.dialogue = storage as! Dialog
    }
    
    static func storage(for object: Object) -> Any {
        return Dialog(for: object)
    }
    
    func handle(_ event: Event) -> Bool {
        switch EventId(rawValue: event.id) {
            case .movedFrom:
                if event.target == object, let location = event.parameters["container"] as? Object {
                    location.remove(observer: object)
                    performActions(inContext: Dialog.Context(speaker: object, subject: object.engine.player, event: event))
                }

            case .movedTo:
                if event.target == object, let location = event.parameters["container"] as? Object {
                    location.add(observer: object)
                    performActions(inContext: Dialog.Context(speaker: object, subject: object.engine.player, event: event))
                }

            case .contentRemoved:
                if event.target == object.location, let object = event[objectWithKey: "object"], object.isPlayer {
                    performActions(inContext: Dialog.Context(speaker: object, subject: object.engine.player, event: event))
                }

            case .contentAdded:
                if event.target == object.location, let object = event[objectWithKey: "object"], object.isPlayer {
                    performActions(inContext: Dialog.Context(speaker: object, subject: object.engine.player, event: event))
                }
                
            default:
                return false
        }
        
        return false
        
    }
    
    func performActions(inContext context: Dialog.Context) {
        if let output = dialogue.speak(inContext: context) {
            object.engine.output(output.line)
            for action in output.actions {
                print(action)
            }
        }
    }
}
