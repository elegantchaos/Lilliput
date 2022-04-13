// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Files

public struct ProjectFolder {
    let url: URL

    public init(url: URL) {
        self.url = url
    }
    
    public func load(into engine: Engine) throws {
        let root = ThrowingManager.folder(for: url)
        try loadPackedObjects(from: root, into: engine)
        try loadObjects(from: root, into: engine)
        try loadStopWords(from: root, into: engine)
    }
    
    func loadStopWords(from root: Folder, into engine: Engine) throws {
        let file = root.file("stop.txt")
        if let text = file.asText {
            engine.stopWords = text.split(separator: "\n")
        }
    }
    
    func loadPackedObjects(from root: Folder, into engine: Engine) throws {
        let folder = root.folder("packed")
        if folder.exists {
            try folder.forEach { item in
                if item.name.pathExtension == "json", let file = item as? ThrowingFile {
                    let definitions = PackedObjectsFile(file: file)
                    try definitions.load(into: engine)
                }
            }
        }
    }
    
    func loadObjects(from root: Folder, into engine: Engine) throws {
        let folder = root.folder("objects")
        if folder.exists {
            try folder.forEach { item in
                if item.name.pathExtension == "json", let file = item as? ThrowingFile {
                    let definition = ObjectFile(file: file)
                    try definition.load(into: engine)
                }
            }
        }
    }
    
    public func convert(url: URL, into: URL) -> [URL] {
        var urls: [URL] = []
        let folder = ThrowingManager.folder(for: url)
        let converted = ThrowingManager.folder(for: into)
        do {
            try folder.forEach { item in
                if item.name.pathExtension == "json", let file = item as? ThrowingFile {
                    let definitions = PackedObjectsFile(file: file)
                    urls.append(contentsOf: try definitions.convert(into: converted))
                }
            }
        } catch {
            print("\(error)")
        }
        
        return urls
    }
    

}
