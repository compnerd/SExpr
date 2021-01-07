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

final class ParseTests: XCTestCase {
  func testParseQuote() {
    let expr: SExpr = "(quote (this is a quoted list))"
    XCTAssertEqual(expr,
      .list([
        .atom(.string("quote")),
        .list([
          .atom(.string("this")),
          .atom(.string("is")),
          .atom(.string("a")),
          .atom(.string("quoted")),
          .atom(.string("list")),
        ])
      ])
    )
  }

  func testParseApply() {
    let expr: SExpr = "(define (f x) x) 1"
    XCTAssertEqual(expr,
      .list([
        .list([
          .atom(.string("define")),
          .list([
            .atom(.string("f")),
            .atom(.string("x")),
          ]),
          .atom(.string("x")),
        ]),
        .atom(.int(1)),
      ])
    )
  }

  func testParseSequence() {
    let expr: SExpr = "1 2"
    XCTAssertEqual(expr,
      .list([
        .atom(.int(1)),
        .atom(.int(2)),
      ])
    )
  }
}

final class EvaluateTests: XCTestCase {
  func testAtomInt() {
    let expr: SExpr = "1"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.int(1)))
  }

  func testAtomDouble() {
    let expr: SExpr = "1.0"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.double(1.0)))
  }

  func testAtomString() {
    let expr: SExpr = "string"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.string("string")))
  }

  func testEmptyExpression() {
    let expr: SExpr = "()"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .nil)
  }

  func testFilteringNils() {
    let expr: SExpr = "() (quote (this is a quoted list))"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result,
      .list([
        .atom(.string("this")),
        .atom(.string("is")),
        .atom(.string("a")),
        .atom(.string("quoted")),
        .atom(.string("list")),
      ])
    )
  }

  func testApplyLambda() {
    let expr: SExpr = "(lambda (x) x) 1"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result,
      .atom(.int(1))
    )
  }

  func testApplyFunction() {
    let expr: SExpr = "(define (f x) x) (f 1)"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result,
      .atom(.int(1))
    )
  }

  func testBindVariable() {
    let expr: SExpr = """
    (define x 1)
    (define (f x) x)
    (f 2)
    """
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.int(2)))
  }
}

final class BuiltinsTests: XCTestCase {
  func testEvaluateQuote() {
    let expr: SExpr = "(quote (this is a quoted list))"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result,
      .list([
        .atom(.string("this")),
        .atom(.string("is")),
        .atom(.string("a")),
        .atom(.string("quoted")),
        .atom(.string("list")),
      ])
    )
  }

  func testEvaluatePlusSimple() {
    let expr: SExpr = "(+ 1 1)"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.int(2)))
  }

  func testEvaluatePlusSubExprs() {
    let expr: SExpr = "(+ (+ 1 1) (+ 1 1))"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.int(4)))
  }

  func testEvaluatePlusVariables() {
    let expr: SExpr = """
    (define x 1)
    (+ x 1)
    """
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .atom(.int(2)))
  }

  func testEvaluatePlusStrings() {
    let expr: SExpr = "(+ \"a\" \"b\")"
    var environment: Environment = .default

    let result = expr.evaluate(in: &environment)
    XCTAssertEqual(result, .nil)
  }
}
