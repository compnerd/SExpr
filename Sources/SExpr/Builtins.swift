//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

internal enum Builtin: String {
  case define
  case lambda
  case quote
}

extension Builtin {
  internal static func special(_ builtin: String) -> Bool {
    return [Builtin.quote.rawValue, Builtin.define.rawValue].contains(builtin)
  }
}

internal func define(_ args: SExpr, _ environment: inout Environment) -> SExpr {
  guard case let .list(exprs) = args, exprs.count == 2 else { return .nil }

  if case let .list(vars) = exprs[0] {
    guard vars.count > 0 else { return .nil }
    guard case let .atom(.string(name)) = vars[0] else { return .nil }

    let bind: [SExpr] = Array<SExpr>(vars.dropFirst(1))
    let body: SExpr = exprs[1]
    environment[name] = .procedure({ args, environment in
      guard case let .list(args) = args else { return .nil }
      let names: [String] = bind.compactMap {
        if case let .atom(.string(name)) = $0 { return name }
        // TODO: should this be a free-variable which is already bound?
        return nil
      }
      var closureEnv = environment
      zip(names, args).forEach { closureEnv.updateValue(.value($1), forKey: $0) }
      return body.evaluate(in: &closureEnv)
    })
  } else if case let .atom(.string(name)) = exprs[0] {
    var closureEnv = environment
    environment[name] = .value(exprs[1].evaluate(in: &closureEnv))
  }

  return .nil
}

internal func lambda(_ args: SExpr, _ environment: inout Environment) -> SExpr {
  guard case let .list(exprs) = args, exprs.count == 2 else { return .nil }

  guard case let .list(bindings) = exprs[0] else { return .nil }
  let name: String = "$\(UInt32.random(in: 1000...9999))"
  let body: SExpr = exprs[1]
  environment[name] = .procedure({ args, environment in
    guard case let .list(args) = args else { return .nil }
    let names: [String] = bindings.compactMap {
      if case let .atom(.string(name)) = $0 { return name }
      // TODO: should this be a free-variable which is already bound?
      return nil
    }
    var closureEnv = environment
    zip(names, args).forEach { closureEnv.updateValue(.value($1), forKey: $0) }
    return body.evaluate(in: &closureEnv)
  })
  return .atom(.string(name))
}

internal func quote(_ args: SExpr, _ environment: inout Environment) -> SExpr {
  guard case let .list(exprs) = args, exprs.count == 1 else { return .nil }
  return exprs[0]
}
