//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

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
