//
//  File.swift
//  
//
//  Created by Sam Developer on 28/02/2021.
//

import Foundation

protocol CommandOwner {
    var commands: [Command] { get }
    var names: [String] { get }
}
