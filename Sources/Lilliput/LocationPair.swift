// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct LocationPair {
    public let id: String
    public let position: Position
    
    init(location: String, position: Position) {
        self.id = location
        self.position = position
    }
    
    init?(from spec: Any?) {
        guard let spec = spec else { return nil }
        
        if let dictionary = spec as? [String:String], let idString = dictionary[.locationKey], let posString = dictionary[.positionKey], let pos = Position(rawValue: posString) {
            id = idString
            position = pos
        } else if let string = spec as? String {
            id = string
            position = .in
        } else {
            print("Bad location spec: \(spec)")
            return nil
        }
    }
    
    var persistenceData: [String] {
        return [id, position.rawValue]
    }
    
    var asInterchange: Any {
        switch position {
            case .in:
                return id
            default:
                let result: [String:Any] = [.locationKey: id, .positionKey: position.rawValue]
                return result
        }
    }
}

extension LocationPair: Comparable {
    public static func < (lhs: LocationPair, rhs: LocationPair) -> Bool {
        if lhs.id == rhs.id {
            return lhs.position < rhs.position
        } else {
            return lhs.id < rhs.id
        }
    }
    
    
}
