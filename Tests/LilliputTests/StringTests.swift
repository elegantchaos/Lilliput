// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/04/2022.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Lilliput
import XCTest
import XCTestExtensions

class StringTests: XCTestCase {
    func testAppendingWords() {
        var s = Sentence()
        s.append("this")
        s.append("is")
        s.append("a")
        s.append("test")
        XCTAssertEqual(s.text, "This is a test.")
    }

    func testAppendingChunks() {
        var s = Sentence()
        s.append("this is")
        s.append("a test")
        XCTAssertEqual(s.text, "This is a test.")
    }

    func testSentence() {
        let s = Sentence("This is a test")
        XCTAssertEqual(s.text, "This is a test.")
    }

    func testSentenceTrailingPunctuation() {
        XCTAssertEqual(Sentence("This is a test.").text, "This is a test.")
        XCTAssertEqual(Sentence("This is a test!").text, "This is a test!")
        XCTAssertEqual(Sentence("This is a test?").text, "This is a test?")
        XCTAssertEqual(Sentence("This is a test:").text, "This is a test:")
    }

    func testParagraph() {
        var p = Paragraph()
        p.append(Sentence("This is a test"))
        p.append(Sentence("Another sentence"))
        XCTAssertEqual(p.text, "This is a test. Another sentence.")
    }
    
    func testSection() {
        var s = Section()
        s.append("This is a paragraph")
        s.append("This is another paragraph")
        XCTAssertEqual(s.text, "This is a paragraph.\n\nThis is another paragraph.")
    }
}
