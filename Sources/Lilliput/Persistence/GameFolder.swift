// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import DictionaryResolver
import Foundation
import Files

/// Structured folder containing all the files that define a game.
public struct GameFolder {
    let url: URL
    var resolver: DictionaryResolver
    
    public init(url: URL) {
        var resolver = DictionaryResolver()
        resolver.addCombiner(Combiner.combineCombinable)

        self.url = url
        self.resolver = resolver
    }
    
    public mutating func load(into engine: Engine) throws {
        let root = ThrowingManager.folder(for: url)
        
        if let url = Bundle.module.url(forResource: "Types", withExtension: "") {
            try resolver.loadRecords(from: url, mode: .oneRecordPerFile)
        }
        
        try loadPackedObjects(from: root)
        try loadObjects(from: root)
        try loadStopWords(from: root, into: engine)
        resolveObjects(into: engine)
    }
    
    func loadStopWords(from root: Folder, into engine: Engine) throws {
        let file = root.file("stop words.txt")
        if let text = file.asText {
            engine.stopWords = text.split(separator: "\n")
        }
    }
    
    mutating func loadPackedObjects(from root: Folder) throws {
        let folder = root.folder("packed")
        if folder.exists {
            try resolver.loadRecords(from: folder.url, mode: .multipleRecordsPerFile)
        }
    }
    
    mutating func loadObjects(from root: Folder) throws {
        let folder = root.folder("objects")
        if folder.exists {
            try resolver.loadRecords(from: folder.url, mode: .oneRecordPerFile)
        }
    }

    mutating func resolveObjects(into engine: Engine) {
        resolver.resolve()
        for (id, properties) in resolver.resolvedRecords {
            let definition = Definition(id: id, properties: properties)
            engine.register(definition)
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
