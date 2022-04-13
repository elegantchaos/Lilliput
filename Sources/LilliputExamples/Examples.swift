// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/03/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct LilliputExamples {
    public static func urlForGame(named name: String) -> URL? {
        return Bundle.module.url(forResource: name, withExtension: "lilliput", subdirectory: "Games")
    }

    public static func urlForDefinition(named name: String) -> URL? {
        return Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Definitions")
    }

    public static func script(named name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "commands", subdirectory: "Commands")
    }
}
