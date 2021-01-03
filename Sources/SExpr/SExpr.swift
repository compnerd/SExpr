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
