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
    
    static func storage(for object: Object) -> Any {
        return ()
    }
    
    func handleWeDeparted(from location: Object) {
        location.remove(observer: object)
    }
    
    func handleWeArrived(in location: Object) {
        location.add(observer: object)
    }
    
    func handlePlayerDeparted(from location: Object) {
        print("Bye!")
    }
    
    func handlePlayerArrived(at location: Object) {
        print("Hello!")
    }
    
    func handle(_ event: Event) -> Bool {
        switch EventId(rawValue: event.id) {
            case .movedFrom:
                if event.target == object, let location = event.parameters["container"] as? Object {
                    handleWeDeparted(from: location)
                }

            case .movedTo:
                if event.target == object, let location = event.parameters["container"] as? Object {
                    handleWeArrived(in: location)
                }

            case .contentRemoved:
                if event.target == object.location, let object = event[objectWithKey: "object"], object.isPlayer {
                    handlePlayerDeparted(from: event.target)
                }

            case .contentAdded:
                if event.target == object.location, let object = event[objectWithKey: "object"], object.isPlayer {
                    handlePlayerArrived(at: event.target)
                }

                
            default:
                return false
        }
        
        return false
        
    }
}
