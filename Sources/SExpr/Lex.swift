//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

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
