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

public enum SExpr {
  case atom(Symbol)
  case list([SExpr])
}
