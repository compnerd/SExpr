//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

import SExpr

var environment: Environment = .default
while true {
  print("\u{03bb}", terminator: " ")
  guard let input = readLine(strippingNewline: false) else { break }
  print("\u{21e8} \(SExpr(stringLiteral: input).evaluate(in: &environment))")
}
