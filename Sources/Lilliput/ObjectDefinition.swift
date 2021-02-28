//
//  File.swift
//  
//
//  Created by Sam Developer on 28/02/2021.
//

import Foundation

public struct ObjectDefinition {
    let id: String
    let strings: [String:String]
    let properties: [String:Any]
    
    init(id: String, properties: [String:Any]) {
        self.id = id
        self.properties = properties
        if let strings = properties["strings"] as? [String:String] {
            self.strings = strings
        } else {
            self.strings = [:]
        }
    }
}

