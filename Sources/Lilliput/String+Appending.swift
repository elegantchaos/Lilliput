// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension String {
    mutating func endSentence() {
        if !isEmpty && (last != ".") {
            append(".")
        }
    }
    
    mutating func startSentence(_ string: String) {
        if !string.isEmpty {
            switch count {
            case 0:
                let shouldDrop = string.first == " "
                append(shouldDrop ? String(string.dropFirst()) : string)
                
            default:
                endSentence()
                continueSentence(string)
            }
        }
    }
    
    mutating func continueSentence(_ string: String) {
        if !string.isEmpty {
            if (last != " ") && (string.first != " ") {
                append(" ")
            }
            
            append(string)
        }
    }
    
    mutating func startParagraph(_ string: String) {
        if !string.isEmpty {
            if !isEmpty {
                endSentence()
                append("\n\n")
            }
            
            continueSentence(string)
        }
    }
}

public struct Sentence {
    var value: String
    
    public init() {
        value = ""
    }
    
    public mutating func append(_ string: String) {
        if !string.isEmpty {
            if let last = value.last, last != " " {
                value.append(" ")
            }
            value.append(string)
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
}

extension Sentence: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

public struct Paragraph {
    var value: [Sentence]
    
    public init() {
        value = []
    }
    
    public mutating func append(_ sentence: Sentence) {
        value.append(sentence)
    }
    
    public var text: String {
        return value.map({ $0.text }).joined(separator: " ")
    }
}

extension Paragraph: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.value = [Sentence(stringLiteral: value)]
    }
}

public struct Section {
    var value: [Paragraph]
    
    public init() {
        value = []
    }
    
    public mutating func append(_ paragraph: Paragraph) {
        value.append(paragraph)
    }
    
    public var text: String {
        return value.map({ $0.text }).joined(separator: "\n\n")
    }
}
