//
//  ParserTests.swift
//  JSON
//
//  Created by Ethan Jackwitz on 4/19/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import XCTest
@testable import JSON

class ParsingTests: XCTestCase {

  func test_FailOnEmpty() {

    expect("", toThrowWithReason: .emptyStream)
  }

  func testExtraTokensThrow() {

    expect("{'hello':'world'} blah", toThrowWithReason: .invalidSyntax)
  }

  func testNullParses() {

    expect("null", toParseTo: .null)
  }

  func testNullThrowsOnMismatch() {

    expect("nall", toThrowWithReason: .invalidLiteral)
  }

  func testTrueParses() {

    expect("true", toParseTo: .bool(true))
  }

  func testTrueThrowsOnMismatch() {

    expect("tRue", toThrowWithReason: .invalidLiteral)
  }

  func testFalseParses() {

    expect("false", toParseTo: .bool(false))
  }

  func testBoolean_False_Mismatch() {

    expect("fals ", toThrowWithReason: .invalidLiteral)
  }

  func testArray_JustComma() {

    expect("[,]", toThrowWithReason: .invalidSyntax)
  }

  func testArray_JustNull() {

    expect("[ null ]", toParseTo: [JSON.null])
  }

  func testArray_NullsBoolsNums_Normal_Minimal_RootParser() {

    expect("[null,true,false,12,-10,-24.3,18.2e9]", toParseTo: .array([
      JSON.null,
      JSON.bool(true),
      JSON.bool(false),
      JSON.integer(12),
      JSON.integer(-10),
      JSON.double(-24.3),
      JSON.double(18200000000)
      ]))
  }

  func testArray_NullsBoolsNums_Normal_MuchWhitespace() {

    expect(" \t[\n  null ,true, \n-12.3 , false\r\n]\n  ", toParseTo: .array([
      JSON.null,
      JSON.bool(true),
      JSON.double(-12.3),
      JSON.bool(false)
      ]))
  }

  func testArray_NullsAndBooleans_Bad_MissingEnd() {

    expect("[\n  null ,true, \nfalse\r\n\n  ", toThrowWithReason: .expectedComma)
  }

  func testArray_NullsAndBooleans_Bad_MissingComma() {

    expect("[\n  null true, \nfalse\r\n]\n  ", toThrowWithReason: .expectedComma)
  }

  func testArray_NullsAndBooleans_Bad_ExtraComma() {

    expect("[\n  null , , true, \nfalse\r\n]\n  ", toThrowWithReason: .invalidSyntax)
  }

  func testArray_NullsAndBooleans_Bad_TrailingComma() {

    expect("[\n  null ,true, \nfalse\r\n, ]\n  ", toThrowWithReason: .trailingComma)
  }

  func testNumber_Int_Zero() {

    expect("0 ", toParseTo: .integer(0))
  }

  func testNumber_Int_One() {

    expect("1", toParseTo: .integer(1))
  }

  func testNumber_Int_Basic() {

    expect("24", toParseTo: .integer(24))
  }

  func testNumber_IntMin() {

    expect(Int.min.description, toParseTo: .integer(Int64.min))
  }

  func testNumber_IntMax() {

    expect(Int.max.description, toParseTo: .integer(Int64.max))
  }

  func testNumber_Int_Negative() {

    expect("-32", toParseTo: .integer(-32))
  }

  func testNumber_Dbl_Basic() {

    expect("46.57", toParseTo: .double(46.57))
  }

  func testNumber_Dbl_ZeroSomething() {

    expect("0.98", toParseTo: .double(0.98))
  }

  func testNumber_Dbl_MinusZeroSomething() {

    expect("-0.98", toParseTo: .double(-0.98))
  }

  func testNumber_Dbl_ThrowsOnMinus() {

    expect("-", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Incomplete() {

    expect("24.", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Negative() {

    expect("-24.34", toParseTo: .double(-24.34))
  }

  func testNumber_Dbl_Negative_WrongChar() {

    expect("-24.3a4", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Negative_TwoDecimalPoints() {

    expect("-24.3.4", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Dbl_Negative_TwoMinuses() {

    expect("--24.34", toThrowWithReason: .invalidNumber)
  }

  func testNumber_Double_Exp_Normal() {

    expect("-24.3245e2", toParseTo: .double(-2432.45))
  }

  func testNumber_Double_Exp_Positive() {

    expect("-24.3245e+2", toParseTo: .double(-2432.45))
  }

  // TODO (vdka): floating point accuracy
  // Potential to fix through using Darwin.C.pow but, isn't that a dependency?
  // Maybe reimplement C's discusting lookup table pow method
  // http://opensource.apple.com/source/Libm/Libm-2026/Source/Intel/expf_logf_powf.c
  // http://opensource.apple.com/source/Libm/Libm-315/Source/ARM/powf.c
  // May be hard to do this fast and correct in pure swift.
  func testNumber_Double_Exp_Negative() {

    // FIXME (vdka): Fix floating point number types
    expect("-24.3245e-2", toParseTo: .double(-24.3245e-2))
  }

  func testNumber_Double_ExactnessNoExponent() {

    expect("-123451123442342.12124234", toParseTo: .double(-123451123442342.12124234123421123411234123412351151))
  }

  func testNumber_Double_ExactnessWithExponent() {

    expect("-123456789.123456789e-150", toParseTo: .double(-123456789.123456789e-150))
  }

  func testNumber_Double_Exp_NoFrac() {

    expect("24E2", toParseTo: .double(2400))
  }

  func testNumber_Double_Exp_TwoEs() {

    expect("-24.3245eE2", toThrowWithReason: .invalidNumber)
  }

  func testEscape_Unicode_Normal() {

    expect("'\\u0048'", toParseTo: .string("H"))
  }

  func testEscape_Unicode_InvalidUnicode_MissingDigit() {

    expect("'\\u048'", toThrowWithReason: .invalidEscape)
  }

  func testEscape_Unicode_InvalidUnicode_MissingAllDigits() {

    expect("'\\u'", toThrowWithReason: .invalidEscape)
  }

  func testString_Empty() {

    expect("''", toParseTo: .string(""))
  }

  func testString_Normal() {

    expect("'hello world'", toParseTo: .string("hello world"))
  }

  func testString_Normal_WhitespaceInside() {

    expect("'he \\r\\n l \\t l \\n o wo\\rrld ' ", toParseTo: .string("he \r\n l \t l \n o wo\rrld "))
  }

  func testString_StartEndWithSpaces() {

    expect("'  hello world  '", toParseTo: .string("  hello world  "))
  }

  func testString_Unicode_RegularChar() {

    expect("'hel\\u006co world'", toParseTo: .string("hello world"))
  }

  func testString_Unicode_SpecialCharacter_CoolA() {

    expect("'h\\u01cdw'", toParseTo: .string("hǍw"))
  }

  func testString_Unicode_SpecialCharacter_HebrewShin() {

    expect("'h\\u05e9w'", toParseTo: .string("hשw"))
  }

  func testString_Unicode_SpecialCharacter_QuarterTo() {

    expect("'h\\u25d5w'", toParseTo: .string("h◕w"))
  }

  func testString_Unicode_SpecialCharacter_EmojiSimple() {

    expect("'h\\ud83d\\ude3bw'", toParseTo: .string("h😻w"))
  }

  func testString_Unicode_SpecialCharacter_EmojiComplex() {

    expect("'h\\ud83c\\udde8\\ud83c\\uddffw'", toParseTo: .string("h🇨🇿w"))
  }

  func testString_SpecialCharacter_QuarterTo() {

    expect("'h◕w'", toParseTo: .string("h◕w"))
  }

  func testString_SpecialCharacter_EmojiSimple() {

    expect("'h😻w'", toParseTo: .string("h😻w"))
  }

  func testString_SpecialCharacter_EmojiComplex() {

    expect("'h🇨🇿w'", toParseTo: .string("h🇨🇿w"))
  }

  func testObject_Empty() {

    expect("{}", toParseTo: .object([]))
  }

  func testObject_Example1() {
    expect("{\t'hello': 'wor🇨🇿ld', \n\t 'val': 1234, 'many': [\n-12.32, null, 'yo'\r], 'emptyDict': {}, 'dict': {'arr':[]}, 'name': true}", toParseTo:
      .object([
        ("hello", .string("wor🇨🇿ld")),
        ("val", .integer(1234)),
        ("many", .array([.double(-12.32), .null, .string("yo")])),
        ("emptyDict", .object([])),
        ("dict", .object([("arr", .array([]))])),
        ("name", .bool(true))
        ])
    )
  }

  func testDetailedError() {

    expect("false blah", toThrow: JSON.Parser.Error(byteOffset: 6, reason: .invalidSyntax))
    expect("0xbadf00d", toThrow: JSON.Parser.Error(byteOffset: 1, reason: .invalidNumber))
  }
}

//  // This should end up throwing an error?
//  func testDuplicateKeys() {
//    // [Section 4](https://tools.ietf.org/html/rfc7159#section-4) of the RFC mentions
//    /*
//     "The names within an object SHOULD be unique."
//     ...
//     "When the names within an object are not
//      unique, the behavior of software that receives such an object is
//      unpredictable.  Many implementations report the last name/value pair
//      only.  Other implementations report an error or fail to parse the
//      object, and some implementations report all of the name/value pairs,
//      including duplicates."
//    */
//    
//    // TODO (vdka): Fail on duplicates option
//    
//    // NOTE: access through the dictionary interface will return the keypair most recently inserted.
//    //  However, both keypairs are stored and accessible through pattern matching notation.
// 
//    let json = try! JSON.Parser.parse("{'a':1,'a':2}".substituting("'", for: "\""))
//    guard case .object(let output) = json else {
//      XCTFail()
//      return
//    }
//    
//    let expectedOutput: [(String, JSON)] = [("a", 1), ("a", 2)]
//    
//    zip(output, expectedOutput).forEach { (output, expectedOutput) in
//      XCTAssert(output == expectedOutput)
//    }
//  }
//}

extension ParsingTests {

  func expect(_ input: String, toThrowWithReason expectedError: JSON.Parser.Error.Reason, file: StaticString = #file, line: UInt = #line) {

    let input = input.replacingOccurrences(of: "'", with: "\"")

    let data = Array(input.utf8)

    do {

      let val = try JSON.Parser.parse(data, options: .allowFragments)

      XCTFail("expected to throw \(expectedError) but got \(val)", file: file, line: line)
    } catch let error as JSON.Parser.Error {

      XCTAssertEqual(error.reason, expectedError, file: file, line: line)
    } catch {

      XCTFail("expected to throw \(expectedError) but got a different error type!.")
    }
  }

  func expect(_ input: String, toThrow expectedError: JSON.Parser.Error, file: StaticString = #file, line: UInt = #line) {

    let input = input.replacingOccurrences(of: "'", with: "\"")

    let data = Array(input.utf8)

    do {

      let val = try JSON.Parser.parse(data, options: .allowFragments)

      XCTFail("expected to throw \(expectedError) but got \(val)", file: file, line: line)
    } catch let error as JSON.Parser.Error {

      XCTAssertEqual(error, expectedError, file: file, line: line)
    } catch {

      XCTFail("expected to throw \(expectedError) but got a different error type!.")
    }
  }

  func expect(_ input: String, toParseTo expected: JSON, file: StaticString = #file, line: UInt = #line) {

    let input = input.replacingOccurrences(of: "'", with: "\"")

    let data = Array(input.utf8)

    do {
      let output = try JSON.Parser.parse(data, options: .allowFragments)

      XCTAssertEqual(output, expected, file: file, line: line)
    } catch {
      XCTFail("\(error)", file: file, line: line)
    }
  }
}

#if os(Linux)
  extension ParsingTests {
    static var allTests : [(String, (ParsingTests) -> () throws -> Void)] {
      return [
        ("test_FailOnEmpty", testPrepareForReading_FailOnEmpty),
        ("testExtraTokensThrow", testExtraTokensThrow),
        ("testNullParses", testNullParses),
        ("testNullThrowsOnMismatch", testNullThrowsOnMismatch),
        ("testTrueParses", testTrueParses),
        ("testTrueThrowsOnMismatch", testTrueThrowsOnMismatch),
        ("testFalseParses", testFalseParses),
        ("testBoolean_False_Mismatch", testBoolean_False_Mismatch),
        ("testArray_NullsBoolsNums_Normal_Minimal_RootParser", testArray_NullsBoolsNums_Normal_Minimal_RootParser),
        ("testArray_NullsBoolsNums_Normal_MuchWhitespace", testArray_NullsBoolsNums_Normal_MuchWhitespace),
        ("testArray_NullsAndBooleans_Bad_MissingEnd", testArray_NullsAndBooleans_Bad_MissingEnd),
        ("testArray_NullsAndBooleans_Bad_MissingComma", testArray_NullsAndBooleans_Bad_MissingComma),
        ("testArray_NullsAndBooleans_Bad_ExtraComma", testArray_NullsAndBooleans_Bad_ExtraComma),
        ("testArray_NullsAndBooleans_Bad_TrailingComma", testArray_NullsAndBooleans_Bad_TrailingComma),
        ("testNumber_Int_Zero", testNumber_Int_Zero),
        ("testNumber_Int_One", testNumber_Int_One),
        ("testNumber_Int_Basic", testNumber_Int_Basic),
        ("testNumber_Int_Negative", testNumber_Int_Negative),
        ("testNumber_Dbl_Basic", testNumber_Dbl_Basic),
        ("testNumber_Dbl_ZeroSomething", testNumber_Dbl_ZeroSomething),
        ("testNumber_Dbl_MinusZeroSomething", testNumber_Dbl_MinusZeroSomething),
        ("testNumber_Dbl_Incomplete", testNumber_Dbl_Incomplete),
        ("testNumber_Dbl_Negative", testNumber_Dbl_Negative),
        ("testNumber_Dbl_Negative_WrongChar", testNumber_Dbl_Negative_WrongChar),
        ("testNumber_Dbl_Negative_TwoDecimalPoints", testNumber_Dbl_Negative_TwoDecimalPoints),
        ("testNumber_Dbl_Negative_TwoMinuses", testNumber_Dbl_Negative_TwoMinuses),
        ("testNumber_Double_Exp_Normal", testNumber_Double_Exp_Normal),
        ("testNumber_Double_Exp_Positive", testNumber_Double_Exp_Positive),
        ("testNumber_Double_Exp_Negative", testNumber_Double_Exp_Negative),
        ("testNumber_Double_Exp_NoFrac", testNumber_Double_Exp_NoFrac),
        ("testNumber_Double_Exp_TwoEs", testNumber_Double_Exp_TwoEs),
        ("testEscape_Unicode_Normal", testEscape_Unicode_Normal),
        ("testEscape_Unicode_InvalidUnicode_MissingDigit", testEscape_Unicode_InvalidUnicode_MissingDigit),
        ("testEscape_Unicode_InvalidUnicode_MissingAllDigits", testEscape_Unicode_InvalidUnicode_MissingAllDigits),
        ("testString_Empty", testString_Empty),
        ("testString_Normal", testString_Normal),
        ("testString_Normal_WhitespaceInside", testString_Normal_WhitespaceInside),
        ("testString_StartEndWithSpaces", testString_StartEndWithSpaces),
        ("testString_Unicode_RegularChar", testString_Unicode_RegularChar),
        ("testString_Unicode_SpecialCharacter_CoolA", testString_Unicode_SpecialCharacter_CoolA),
        ("testString_Unicode_SpecialCharacter_HebrewShin", testString_Unicode_SpecialCharacter_HebrewShin),
        ("testString_Unicode_SpecialCharacter_QuarterTo", testString_Unicode_SpecialCharacter_QuarterTo),
        ("testString_Unicode_SpecialCharacter_EmojiSimple", testString_Unicode_SpecialCharacter_EmojiSimple),
        ("testString_Unicode_SpecialCharacter_EmojiComplex", testString_Unicode_SpecialCharacter_EmojiComplex),
        ("testString_SpecialCharacter_QuarterTo", testString_SpecialCharacter_QuarterTo),
        ("testString_SpecialCharacter_EmojiSimple", testString_SpecialCharacter_EmojiSimple),
        ("testString_SpecialCharacter_EmojiComplex", testString_SpecialCharacter_EmojiComplex),
        ("testObject_Empty", testObject_Empty),
        ("testObject_Example1", testObject_Example1),
        ("testDetailedError", testDetailedError),
      ]
    }
  }
#endif
