// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 01/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension String {
    static let awareFlag = "aware"
    static let visitedFlag = "visited"
}

struct PlayerBehaviour: Behaviour {
    static var id: String { "player" }
    static var commands: [Command] {
        [
            DebugCommand(),
            GoCommand(),
            InventoryCommand(),
            StandCommand(),
            TeleportCommand(),
            
            ExamineFallbackCommand(),
            GoFallbackCommand(),
            TakeFallbackCommand(),
            SwearFallbackCommand(),
            LeaveFallbackCommand(),
        ]
    }

    class PlayerStats {
        init(for object: Object) {
            
        }
    }
    
    let object: Object
    let stats: PlayerStats
    
    init(_ object: Object, storage: Any) {
        self.object = object
        self.stats = storage as! PlayerStats
    }
    
    static func storage(for object: Object) -> Any {
        return PlayerStats(for: object)
    }
    
    func handle(_ event: Event) -> EventResult {
        guard let id = EventID(rawValue: event.id) else { return .unhandled }
        switch id {
            case .moved:
                assert(event.target == object)
                if let location = event[objectWithKey: .toParameter] {
                    location.setFlag(.visitedFlag)
                    location.setFlag(.awareFlag)
                    if !location.hasFlag("dontLookWhenArriving") && !event[boolWithKey: "quiet"] {
                        let description = describeLocation()
                        object.engine.output(description)
                    }
                } else {
                    object.engine.warning("Player has no location!")
                }
                return .handled
                
            default:
                return .unhandled
        }
    }

    func showInventory() {
        var worn: [String] = []
        var held: [String] = []
        
        let engine = object.engine
        object.contents.forEach { object, position in
            object.setFlag(.awareFlag)
            let brief = object.getIndefinite()
            if position == .worn {
                worn.append(brief)
            } else {
                let extra = (position == .in) ? "" : " (\(position.rawValue))"
                held.append("\(brief)\(extra)")
            }
        }
        
        if (held.count + worn.count) == 0 {
            engine.output("You are not carrying anything.")
        } else {
            if held.count > 0 {
                engine.output("You are carrying \(engine.asList(held)).")
            }
            
            if worn.count > 0 {
                engine.output("You are wearing \(engine.asList(worn)).")
            }
        }
    }
    
    func describeLocation() -> String {
        var locations: [Object] = []
        var context = DescriptionContext.location
        var prefix = ""
        var output = ""
        let engine = object.engine
        var next = object.location
        while let location = next {
            locations.append(location)
            output += location.getDescription(context: context, prefix: prefix)
            next = location.location
            if next != nil {
                context = .container
                prefix = location.getDescription(for: .outside) ?? ""
            }
        }

        context = .locationContent
        for location in locations {
            // description of contents
            let description = location.describeContents(context: context)
            if !description.isEmpty {
                output += "\n\n\(description)"
            }
            context = .locationContentRecursive
            
            // optional extra descriptions when certain objects are missing
            for entry in location.definition.strings.table {
                var key = entry.key
                if let range = key.range(of: "missing.", options: .anchored) {
                    key.removeSubrange(range)
                    if let object = engine.objects[key] {
                        if !location.contains(object, recursive: false) {
                            output += engine.string(fromAlternatives: entry.value)
                        }
                    }
                }
            }
            
            // append suffix
            if let string = location.getDescription(for: .locationSuffix) {
                output += string
            }
            
            // append exit descriptions
            if let exits = LocationBehaviour(location)?.describeExits(), !exits.isEmpty {
                output += "\n\n\(exits)"
            }
        }
        
        return output
    }
    
    
}
