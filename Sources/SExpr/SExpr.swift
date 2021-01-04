//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

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
    self = SExpr(string.tokens())
  }
}

extension SExpr {
  public func evaluate(in environment: inout Environment) -> SExpr {
    switch self {
    case let .atom(symbol):
      if case let .string(identifier) = symbol {
        if let definition = environment[identifier],
            case let .value(value) = definition {
          return value
        }
      }
      return self

    case var .list(elements):
      guard elements.count > 0 else { return .nil }

      if case let .atom(.string(identifier)) = elements[0] {
        if case let .procedure(body) = environment[identifier] {
          elements = Array<SExpr>(elements.dropFirst(1))
          if !Builtins.special(identifier) {
            elements = elements.map { $0.evaluate(in: &environment) }
          }
          return body(.list(elements), &environment)
        }
      }

      let result: SExpr = .list(elements.map { $0.evaluate(in: &environment) }
                                        .filter { $0 != .nil })
      if result == .nil { return .nil }
      if case let .list(elements) = result, elements.count == 1 {
        return elements[0]
      }
      return result.evaluate(in: &environment)
    }
  }
}
