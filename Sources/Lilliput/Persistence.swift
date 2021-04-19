// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 02/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Files
import Foundation

typealias PersistenceData = [String:Any]

extension String {
    static let behavioursKey = "behaviours"
    static let locationKey = "location"
    static let positionKey = "position"
    static let propertiesKey = "properties"
}

extension Engine {
    
    func save(to name: String) {
        let saves = ThrowingManager.folder(for: URL(fileURLWithPath: "Saves"))
        try? saves.create()

        let file = saves.file(ItemName(name, pathExtension: .gameFileExtension))
        
        var dump: PersistenceData = [:]
        for object in objects {
            dump[unlessEmpty: object.key] = object.value.persistenceData
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

    func restore(from data: PersistenceData) {
        resetObjects()
        for item in data {
            if let object = objects[item.key] {
                let objectData = (item.value as? PersistenceData) ?? [:]
                object.restore(from: objectData)
            }
        }
    }
    

}

extension Object {
    
    var persistenceData: PersistenceData {
        var data: PersistenceData = [:]
        if (locationPair != definition.location) {
            var locationRecord: [String:String] = [:]
            locationRecord[unlessEmpty: .locationKey] = location?.id
            locationRecord[unlessEmpty: .positionKey] = position.rawValue
            data[.locationKey] = locationRecord
            print("Location data \(locationRecord) saved for \(id)")
        }

        var properties = overrides
        properties.removeValue(forKey: .locationKey)
        properties.removeValue(forKey: .positionKey)
        data[unlessEmpty: .propertiesKey] = properties

        var behaviourData: PersistenceData = [:]
        forEachBehaviour { behaviour in
            behaviourData[unlessEmpty: behaviour.id] = behaviour.persistenceData
        }
        data[unlessEmpty: .behavioursKey] = behaviourData

        print("Saved properties for \(id): \(data)")

        return data
    }
    
    func restore(from data: PersistenceData) {
        if let locationSpec = LocationPair(from: data[.locationKey]) {
            guard let location = engine.objects[locationSpec.id] else {
                engine.error("Missing location for \(self)")
            }
            
            move(to: location, position: locationSpec.position, quiet: true)
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
