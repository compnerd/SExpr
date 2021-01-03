//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

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
