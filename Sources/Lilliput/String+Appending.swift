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
