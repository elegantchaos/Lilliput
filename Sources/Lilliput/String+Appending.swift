// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public protocol TextComponent {
    var text: String { get }
}

public struct Text: TextComponent {
    var value: String
    
    public init() {
        value = ""
    }
    
    public init(_ string: String) {
        self.value = string
    }
    
    public mutating func append(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            if let last = value.last, last != " " {
                value.append(" ")
            }
            value.append(trimmed)
        }
    }

    public var text: String {
        return value
    }
    
    static func +=(lhs: inout Text, rhs: String) {
        lhs.append(rhs)
    }
}

extension Text: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}


public struct Sentence: TextComponent {
    var value: String
    
    public init() {
        value = ""
    }
    
    public init(_ string: String) {
        self.value = string
    }
    
    public mutating func append(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            if let last = value.last, last != " " {
                value.append(" ")
            }
            value.append(trimmed)
        }
    }

    public var text: String {
        guard value.count > 0 else { return "" }
        var buffer = value
        if let first = value.first?.uppercased() {
            buffer = "\(first)\(value.dropFirst())"
        }
        
        if let last = buffer.last, !last.isPunctuation {
            buffer.append(".")
        }
        
        return buffer
    }
    
    static func +=(lhs: inout Sentence, rhs: String) {
        lhs.append(rhs)
    }
}

extension Sentence: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

public struct Paragraph: TextComponent {
    var value: [Sentence]
    
    public init() {
        value = []
    }
    
    public init(_ string: String) {
        value = [Sentence(string)]
    }

    public init(_ sentence: Sentence) {
        value = [sentence]
    }
    
    public mutating func append(_ sentence: Sentence) {
        if !sentence.value.isEmpty {
            value.append(sentence)
        }
    }

    public mutating func append(_ component: TextComponent) {
        append(Sentence(component.text))
    }

    public var text: String {
        return value.map({ $0.text }).joined(separator: " ")
    }

    static func +=(lhs: inout Paragraph, rhs: Sentence) {
        lhs.append(rhs)
    }

    static func +=(lhs: inout Paragraph, rhs: TextComponent) {
        lhs.append(rhs)
    }

    static func +=(lhs: inout Paragraph, rhs: String) {
        lhs.append(Sentence(rhs))
    }
}

extension Paragraph: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = [Sentence(stringLiteral: value)]
    }
}

public struct Section: TextComponent {
    var value: [Paragraph]
    
    public init() {
        value = []
    }
    
    public mutating func append(_ paragraph: Paragraph) {
        value.append(paragraph)
    }
    
    public mutating func append(_ sentence: Sentence) {
        var last = value.count > 0 ? value.removeLast() : Paragraph()
        last.append(sentence)
        value.append(last)
    }

    public mutating func append(_ string: StringLiteralType) {
        append(Sentence(string))
    }
    
    public var text: String {
        return value.map({ $0.text }).joined(separator: "\n\n")
    }

    static func +=(lhs: inout Section, rhs: Paragraph) {
        lhs.append(rhs)
    }

    static func +=(lhs: inout Section, rhs: Sentence) {
        lhs.append(rhs)
    }

    static func +=(lhs: inout Section, rhs: String) {
        lhs.append(Sentence(rhs))
    }
}

public struct ItemList: TextComponent {
    let prefix: String
    let items: [String]
    
    public init(_ prefix: String, items: [String]) {
        self.prefix = prefix
        self.items = items
    }
    
    public var text: String {
        switch items.count {
            case 0:
                return ""
                
            case 1:
                return "\(prefix) \(items.first!)"
                
            default:
                let last = items.last!
                let rest = items.dropLast().joined(separator: ", ")
                return "\(prefix) \(rest) and \(last)"
        }
    }
}
