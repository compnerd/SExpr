//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

internal enum Builtin: String {
  case addition = "+"
  case substraction = "-"
  case multiplication = "*"
  case division = "/"

  case define
  case lambda
  case quote
}

extension Builtin: CaseIterable {
}

extension Builtin {
  internal static func special(_ builtin: String) -> Bool {
    return [Builtin.quote.rawValue, Builtin.define.rawValue].contains(builtin)
  }
}

internal func define$(_ expr: SExpr, _ environment: inout Environment) -> SExpr {
  guard case let .list(exprs) = expr, exprs.count == 2 else { return .nil }

  if case let .list(vars) = exprs[0] {
    guard vars.count > 0 else { return .nil }
    guard case let .atom(.string(name)) = vars[0] else { return .nil }

    let bind: [SExpr] = Array<SExpr>(vars.dropFirst(1))
    let body: SExpr = exprs[1]
    environment[name] = .procedure({ expr, environment in
      guard case let .list(args) = expr else { return .nil }
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

internal func lambda$(_ expr: SExpr, _ environment: inout Environment) -> SExpr {
  guard case let .list(exprs) = expr, exprs.count == 2 else { return .nil }

  guard case let .list(bindings) = exprs[0] else { return .nil }
  let name: String = "$\(UInt32.random(in: 1000...9999))"
  let body: SExpr = exprs[1]
  environment[name] = .procedure({ expr, environment in
    guard case let .list(args) = expr else { return .nil }
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

internal func quote$(_ expr: SExpr, _ environment: inout Environment) -> SExpr {
  guard case let .list(exprs) = expr, exprs.count == 1 else { return .nil }
  return exprs[0]
}

internal func op(_ integral: @escaping (Int, Int) -> Int,
                 _ real: @escaping (Double, Double) -> Double)
    -> (SExpr, inout Environment) -> SExpr {
  func value(of expr: SExpr, in environment: Environment) -> SExpr {
    switch expr {
    case .atom(.int(_)):
      return expr
    case .atom(.double(_)):
      return expr
    case let .atom(.string(name)):
      // TODO: error: we must have a binding
      guard let binding = environment[name] else { return .nil }

      switch binding {
      case let .value(bound):
        return value(of: bound, in: environment)
      default:
        // TODO: error: invalid type
        return .nil
      }
    default:
      var closureEnv = environment
      return value(of: expr.evaluate(in: &closureEnv), in: environment)
    }
  }

  return { (_ expr: SExpr, _ environment: inout Environment) -> SExpr in
    // TODO: convert this to > 1, and map `+` over the arguments
    guard case let .list(exprs) = expr, exprs.count == 2 else { return .nil }

    guard case let .atom(lhs) = value(of: exprs[0], in: environment),
          case let .atom(rhs) = value(of: exprs[1], in: environment) else {
      // TODO: report error
      return .nil
    }

    switch (lhs, rhs) {
    case let (.double(lhs), .double(rhs)):
      return .atom(.double(real(lhs, rhs)))
    case let (.int(lhs), .int(rhs)):
      return .atom(.int(integral(lhs, rhs)))
    default:
      // TODO: report error
      return .nil
    }
  }
}

extension Builtin {
  internal var name: String {
    return self.rawValue
  }

  internal var value: Value {
    switch self {
    case .addition: return .procedure(op({ $0 + $1 }, { $0 + $1 }))
    case .substraction: return .procedure(op({ $0 - $1 }, { $0 - $1 }))
    case .multiplication: return .procedure(op({ $0 * $1 }, { $0 * $1 }))
    case .division: return .procedure(op({ $0 / $1 }, { $0 / $1 }))

    case .define: return .procedure(define$)
    case .lambda: return .procedure(lambda$)
    case .quote: return .procedure(quote$)
    }
  }
}
