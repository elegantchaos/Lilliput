// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Files
import Foundation

public class Engine {
    let driver: Driver
    var definitions: [String:ObjectDefinition]
    
    public init(driver: Driver) {
        self.driver = driver
        self.definitions = [:]
    }
    
    public func load(url: URL) {
        let folder = FileManager.default.locations.folder(for: url)
        do {
            try folder.forEach { item in
                if let file = item as? ThrowingFile {
                    let definitions = DefinitionsFile(file: file)
                    try definitions.load(into: self)
                }
            }
        } catch {
                driver.error("\(error)")
        }
            
    }

    public func output(_ string: String) {
        driver.output(string)
    }
    
    public func warning(_ string: String) {
        
    }
    
    public func error(_ string: String) {
        
    }
    
    public func run() {
        var running = true
        
        while running {
            let input = driver.getInput()
            switch input.command {
                case "quit", "q":
                    running = false
                    
                default:
                    print(input)
            }
        }
    }
    
    public func register(definition: ObjectDefinition) {
        definitions[definition.id] = definition
        print("registered \(definition.id)")
    }
}
