//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

import XCTest

@testable
import SExpr

extension Token: Equatable {
  public static func == (_ lhs: Token, _ rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case (.lparen, .lparen), (.rparen, .rparen):
      return true
    case let (.symbol(lhs), .symbol(rhs)) where lhs == rhs:
      return true
    default:
      return false
    }
  }
}

final class LexTests: XCTestCase {
  func testLexAtom() {
    let tokens = tokenise("atom")
    XCTAssertEqual(tokens.count, 1)
    XCTAssertEqual(tokens,
      [
        Token.symbol(.string("atom")),
      ]
    )
  }

  func testLexTypes() {
    let tokens = tokenise("1 1.0 string")
    XCTAssertEqual(tokens.count, 3)
    XCTAssertEqual(tokens,
      [
        Token.symbol(.int(1)),
        Token.symbol(.double(1.0)),
        Token.symbol(.string("string")),
      ]
    )
  }

  func testLexList() {
    let tokens = tokenise("(quote a)")
    XCTAssertEqual(tokens.count, 4)
    XCTAssertEqual(tokens,
      [
        Token.lparen,
        Token.symbol(.string("quote")),
        Token.symbol(.string("a")),
        Token.rparen,
      ]
    )
  }

  func testLexSequential() {
    let tokens = tokenise("(lambda (x) x) ()")
    XCTAssertEqual(tokens,
      [
        Token.lparen,
        Token.symbol(.string("lambda")),
        Token.lparen,
        Token.symbol(.string("x")),
        Token.rparen,
        Token.symbol(.string("x")),
        Token.rparen,
        Token.lparen,
        Token.rparen,
      ]
    )
  }
}
