//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

extension CharacterSet {
  internal static var lparen: CharacterSet {
    CharacterSet(charactersIn: "(")
  }

  internal static var rparen: CharacterSet {
    CharacterSet(charactersIn: ")")
  }

  internal static var atom: CharacterSet {
    CharacterSet(charactersIn: "()").union(.whitespacesAndNewlines)
  }
}
