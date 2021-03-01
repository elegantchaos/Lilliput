// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

struct PlayerTrait: Trait {
    static var id: String { "player" }
    static var commands: [Command] {
        [
            DebugCommand(),
            ExamineCommand(shouldMatchTarget: false),
            GoCommand(),
            InventoryCommand()
        ]
    }
    
    init(with object: Object) {
    }

    func showInventory(of player: Object) {
        var worn: [String] = []
        var held: [String] = []
        
        player.contents.forEach { object, position in
            let brief = object.getIndefinite()
            if position == .worn {
                worn.append(brief)
            } else {
                let extra = (position == .in) ? "" : " (\(position.rawValue))"
                held.append("\(brief)\(extra)")
            }
        }
        
        if (held.count + worn.count) == 0 {
            player.engine.output("You are not carrying anything.")
        } else {
            if held.count > 0 {
                let list = held.joined(separator: ", ")
                player.engine.output("You are carrying \(list).")
            }
            
            if worn.count > 0 {
                let list = worn.joined(separator: ", ")
                player.engine.output("You are wearing \(list).")
            }
        }
    }
    
    func showLocation(object: Object) {
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
    
    func handle(_ event: Event) -> Bool {
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

extension Object {
    func showInventory() {
        if let aspect = self.aspect(PlayerTrait.self) {
            aspect.showInventory(of: self)
        }
    }
}
