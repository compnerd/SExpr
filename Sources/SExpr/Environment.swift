//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

public enum Value {
  case value(SExpr)
  case procedure((SExpr, inout Environment) -> SExpr)
}

public typealias Environment = [String: Value]

extension Environment {
  public static var `default`: Environment {
    return Environment(uniqueKeysWithValues: Builtin.allCases.map {
      ($0.name, $0.value)
    })
  }
}
