// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct PlayerTrait: Trait {
    static var id: String { "player" }
    static var commands: [Command] { [ExamineCommand(shouldMatchTarget: false)]}
    
    static func showLocation(object: Object) {
        var locations: [Object] = []
        var context = DescriptionContext.location
        var prefix = ""
        var next = object.location
        while let location = next {
            locations.append(location)
            location.showDescription(context: context, prefix: prefix)
            next = location.location
            if next != nil {
                context = .container
                prefix = location.getDescription(for: .outside) ?? ""
            }
        }

        for location in locations {
            location.showContents(context: .location, prefix: "You can see")
            location.showExits()
        }
    }
    
    static func handle(_ event: Event) -> Bool {
        guard let id = EventId(rawValue: event.id) else { return false }
        switch id {
            case .movedTo:
                showLocation(object: event.target)
                return true
                
            default:
                return false
        }
    }
}
