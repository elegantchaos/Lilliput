// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Files
import Foundation

typealias PersistenceData = [String:Any]

extension String {
    static let propertiesKey = "properties"
    static let locationKey = "location"
    static let behavioursKey = "behaviours"
}

extension Engine {
    
    func save(to name: String) {
        let saves = ThrowingManager.folder(for: URL(fileURLWithPath: "Saves"))
        try? saves.create()

        let file = saves.file(ItemName(name, pathExtension: .gameFileExtension))
        
        var dump: PersistenceData = [:]
        for object in objects {
            dump[unlessEmpty: object.key] = object.value.saveData
        }

        do {
            let json = try JSONSerialization.data(withJSONObject: dump, options: [.prettyPrinted, .sortedKeys])
            file.write(asData: json)
        } catch {
            warning("Failed to save \(name).\n\(error)")
        }
    }
    
    func restore(from name: String) {
        let saves = ThrowingManager.folder(for: URL(fileURLWithPath: "Saves"))
        let file = saves.file(ItemName(name, pathExtension: .gameFileExtension))
        if let data = file.asData {
            do {
                let dump = try JSONSerialization.jsonObject(with: data, options: [])
                if let items = dump as? PersistenceData {
                    restore(from: items)
                }
            } catch {
                warning("Failed to restore \(name).\n\(error)")
            }
        }
    }
    
}

extension Object {
    
    var saveData: PersistenceData {
        var data: PersistenceData = [:]
        
        data[unlessEmpty: .propertiesKey] = overrides

        if let location = location {
            if (location.id != definition.location?.id) || (position != definition.location?.position) {
                data[.locationKey] = [location.id, position.rawValue]
            }
        }

        var behaviourData: PersistenceData = [:]
        forEachBehaviour { behaviour in
            behaviourData[unlessEmpty: behaviour.id] = behaviour.persistenceData
        }
        data[unlessEmpty: .behavioursKey] = behaviourData

        return data
    }
    
    func restore(from data: PersistenceData) {
        if let location = LocationPair(from: data[.locationKey]) ?? definition.location {
            guard let location = engine.objects[location.id] else { engine.error("Missing location for \(self)")}
            move(to: location, position: location.position)
        }
        
        overrides = (data[.propertiesKey] as? [String:Any]) ?? [:]
        
        data.with(keyName: .behavioursKey) { (behaviourData: PersistenceData) in
            forEachBehaviour { behaviour in
                behaviourData.with(keyName: behaviour.id) { (data: PersistenceData) in
                    behaviour.restore(from: data)
                }
            }
        }

    }
}
