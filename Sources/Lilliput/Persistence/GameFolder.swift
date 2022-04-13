// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Files

/// Structured folder containing all the files that define a game.
public struct GameFolder {
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
        let file = root.file("stop words.txt")
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
            try loadObjects(from: folder, prefix: "", into: engine)
        }
    }

    func loadObjects(from folder: Folder, prefix: String, into engine: Engine) throws {
        try folder.forEach(recursive: false) { item in
            if item.name.pathExtension == "json", let file = item as? ThrowingFile {
                let definition = ObjectFile(file: file, idPrefix: prefix)
                try definition.load(into: engine)
            } else if let subfolder = item as? ThrowingFolder {
                try loadObjects(from: subfolder, prefix: "\(prefix)\(subfolder.name).", into: engine)
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
