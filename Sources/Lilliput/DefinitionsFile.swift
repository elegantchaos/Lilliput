// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Files

struct DefinitionsFile {
    let file: ThrowingFile
    
    init(file: ThrowingFile) {
        self.file = file
    }
    
    func load(into engine: Engine) throws {
        if let data = file.asData {
            let decoded = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let definitions = decoded as? [String:Any] {
                var count = 0
                for item in definitions {
                    if let properties = item.value as? [String:Any] {
                        let definition = Definition(id: item.key, properties: properties)
                        engine.register(definition)
                        count += 1
                    } else {
                        engine.warning("Invalid definition \(item).")
                    }
                }
                
                engineChannel.log("Loaded \(count) definitions from \(file.name).")
            }
        }
        
    }
}
