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
