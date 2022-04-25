// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import Foundation
import Files

/// File containing the definition of a single object.
struct ObjectFile {
    let file: ThrowingFile
    let id: String
    
    init(file: ThrowingFile, idPrefix: String = "") {
        self.file = file
        self.id = "\(idPrefix)\(file.name.name)"
    }
    
    func load(into engine: Engine) throws {
        if let data = file.asData {
            do {
                let decoded = try JSONSerialization.jsonObject(with: data, options: [])
                if let properties = decoded as? [String:Any] {
                    let definition = Definition(id: id, properties: properties)
                    engine.register(definition)
                    engineChannel.log("Loaded \(id) definition.")
                }
            } catch {
                let nserror = error as NSError
                if (nserror.domain == NSCocoaErrorDomain) && (nserror.code == 3840) {
                    if let json = String(data: data, encoding: .utf8),
                       let description = nserror.userInfo["NSDebugDescription"] as? String,
                       let number = description.split(separator: " ").last?.split(separator: ".").first,
                       let index = Int(number) {
                        
                        let lines = json.split(separator: "\n")
                        var count = 0
                        for n in 0 ..< lines.count {
                            count = count + lines[n].count
                            if count > index {
                                print("Error")
                                if n > 0 {
                                    print("\(n - 1): \(lines[n - 1])")
                                }
                                print("\(n): \(lines[n])")
                                if n + 1 < lines.count {
                                    print("\(n + 1): \(lines[n + 1])")
                                }
                                throw error
                            }
                        }
                    }
                }
                
                throw error
            }
        }
    }
    
    func convert(into destination: Folder) throws -> [URL] {
        var urls: [URL] = []
        try destination.create()
        if let data = file.asData {
            let decoded = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let definitions = decoded as? [String:Any] {
                for (id, definition) in definitions {
                    let encoded = try JSONSerialization.data(withJSONObject: definition, options: [.prettyPrinted, .sortedKeys])
                    var components = id.split(separator: ".")
                    var container = destination
                    while components.count > 1 {
                        container = container.folder(String(components.removeFirst()))
                    }
                    try container.create()
                    let output = container.file(ItemName(String(components[0]), pathExtension: "json"))
                    output.write(asData: encoded)
                    urls.append(output.url)
                }
            }
        }
        
        return urls
    }
    
    
}
