//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

public enum Symbol {
  case int(Int)
  case double(Double)
  case string(String)
}

extension Symbol: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .int(integer):
      return "\(integer)"
    case let .double(real):
      return "\(real)"
    case let .string(string):
      return string
    }
  }
}

extension Symbol: Equatable {
  public static func == (_ lhs: Symbol, _ rhs: Symbol) -> Bool {
    switch (lhs, rhs) {
    case let (.int(lhs), .int(rhs)) where lhs == rhs:
      return true
    case let (.double(lhs), .double(rhs)) where lhs == rhs:
      return true
    case let (.string(lhs), .string(rhs)) where lhs == rhs:
      return true
    default:
      return false
    }
  }
}

public enum SExpr {
  case atom(Symbol)
  case list([SExpr])
}

extension SExpr {
  public static var `nil`: SExpr {
    .list([])
  }
}

extension SExpr: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .atom(symbol):
      return "\(symbol)"
    case .list([]):
      return "nil"
    case let .list(expressions):
      return "(\(expressions.map { "\($0)" }.joined(separator: " ")))"
    }
  }
}

extension SExpr: Equatable {
  public static func == (_ lhs: SExpr, _ rhs: SExpr) -> Bool {
    switch (lhs, rhs) {
    case let (.atom(lhs), .atom(rhs)) where lhs == rhs:
      return true
    case let (.list(lhs), .list(rhs)) where lhs == rhs:
      return true
    default:
      return false
    }
  }
}

extension SExpr: ExpressibleByStringLiteral {
  public init(stringLiteral string: String) {
    self = parse(tokenise(string)).expression
  }
}

enum Token {
  case lparen
  case rparen
  case symbol(Symbol)
}

func tokenise(_ expr: String) -> [Token] {
  var tokens: [Token] = []

  let scanner: Scanner = Scanner(string: expr)
  while !scanner.isAtEnd {
    if let lparens = scanner.scanCharacters(from: .lparen) {
      for _ in 1...lparens.count { tokens.append(.lparen) }
    }
    if let string = scanner.scanUpToCharacters(from: .atom) {
      string.split(separator: " ").forEach {
        if let int = Int($0) {
          tokens.append(.symbol(.int(int)))
        } else if let double = Double($0) {
          tokens.append(.symbol(.double(double)))
        } else {
          tokens.append(.symbol(.string(String($0))))
        }
      }
    }
    if let rparens = scanner.scanCharacters(from: .rparen) {
      for _ in 1...rparens.count { tokens.append(.rparen) }
    }
  }

  return tokens
}

func append(_ node: SExpr, to list: SExpr?) -> SExpr {
  if let list = list {
    switch list {
    case var .list(nodes):
      nodes.append(node)
      return .list(nodes)
    case let .atom(atom):
      return .list([.atom(atom), node])
    }
  }
  return node
}

func parse(_ tokens: [Token], into node: SExpr? = nil)
    -> (expression: SExpr, tail: [Token]) {
  var tokens = tokens
  var node = node

  while let token = tokens.popFront() {
    switch token {
    case .lparen:
      let (expr, tail) = parse(tokens, into: .nil)
      tokens = tail
      node = append(expr, to: node ?? .nil)
    case .rparen:
      // TODO: diagnose unmatched ')'
      return (node!, tokens)
    case let .symbol(symbol):
      node = append(.atom(symbol), to: node)
    }
  }

  if case let .list(expressions) = node, expressions.count == 1 {
    node = expressions[0]
  }
  return (node ?? .nil, tokens)
}
