// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let visitedFlag = "visited"
}

struct PlayerBehaviour: Behaviour {
    static var id: String { "player" }
    static var commands: [Command] {
        [
            DebugCommand(),
            ExamineCommand(shouldMatchTarget: false),
            GoCommand(),
            InventoryCommand()
        ]
    }

    let object: Object
    
    init(_ object: Object, storage: Any) {
        self.object = object
    }
    
    static func storage(for object: Object) -> Any {
        return ()
    }
    
    func handle(_ event: Event) -> Bool {
        guard let id = EventId(rawValue: event.id) else { return false }
        switch id {
            case .movedTo:
                assert(event.target == object)
                object.location?.setFlag(.visitedFlag)
                showLocation()
                return true
                
            default:
                return false
        }
    }

    func showInventory() {
        var worn: [String] = []
        var held: [String] = []
        
        object.contents.forEach { object, position in
            let brief = object.getIndefinite()
            if position == .worn {
                worn.append(brief)
            } else {
                let extra = (position == .in) ? "" : " (\(position.rawValue))"
                held.append("\(brief)\(extra)")
            }
        }
        
        if (held.count + worn.count) == 0 {
            object.engine.output("You are not carrying anything.")
        } else {
            if held.count > 0 {
                let list = held.joined(separator: ", ")
                object.engine.output("You are carrying \(list).")
            }
            
            if worn.count > 0 {
                let list = worn.joined(separator: ", ")
                object.engine.output("You are wearing \(list).")
            }
        }
    }
    
    func showLocation() {
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
            location.showContents(context: .location)
            LocationBehaviour(location)?.showExits()
        }
    }
}
