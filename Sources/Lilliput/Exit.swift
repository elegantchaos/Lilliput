//
//  File.swift
//  
//
//  Created by Sam Developer on 28/02/2021.
//

import Foundation

struct Exit {
    let destination: Object
    let portal: Object?
    
    init(to destination: Object, portal: Object? = nil) {
        self.destination = destination
        self.portal = portal
    }
}
