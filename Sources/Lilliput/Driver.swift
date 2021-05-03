// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 28/02/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct Input {
    let raw: String
    let cleaned: String
    let command: String
//    let arguments: [String]

    public init?(_ string: String, stopWords: [String.SubSequence]) {
        let trimmed = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let words = trimmed.split(separator: " ").filter({ !stopWords.contains($0) })
        guard words.count > 0 else { return nil }
        let cleaned = words.joined(separator: " ")

        let command = String(words[0])
        let args = words.dropFirst().map({ String($0) })
        self.init(raw: string, cleaned: cleaned, command: command, arguments: args)
    }
    
    public init(raw: String, cleaned: String, command: String, arguments: [String]) {
        self.raw = raw
        self.cleaned = cleaned
        self.command = command
//        self.arguments = arguments
    }
}

public enum OutputType {
    case rawInput
    case input
    case debug
    case normal
    case append
    case option
    case dialogue
    case warning
    case prompt
    case error
}

public protocol Driver {
    func pushInput(_ string: String)
    func getInput(stopWords: [String.SubSequence]) -> Input
    func output(_ string: String, type: OutputType)
}

public extension Driver {
    func pushInput(_ string: String) {
    }
}
