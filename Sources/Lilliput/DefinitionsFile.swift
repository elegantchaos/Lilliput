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
            do {
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
                    let output = destination.file(ItemName(id, pathExtension: "json"))
                    output.write(asData: encoded)
                    urls.append(output.url)
                }
            }
        }
        
        return urls
    }
    

}
