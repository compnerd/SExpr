//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

enum Builtins: String {
  case define
  case lambda
  case quote
}

extension Builtins {
  static func special(_ string: String) -> Bool {
    return string == Builtins.quote.rawValue || string == Builtins.define.rawValue
  }
}

public enum Value {
  case value(SExpr)
  case procedure((SExpr, inout Environment) -> SExpr)
}

public typealias Environment = [String: Value]

extension Environment {
  public static var `default`: Environment {
    return [
      Builtins.define.rawValue: .procedure({ args, environment in
        guard case let .list(args) = args, args.count == 2 else { return .nil }

        guard case var .list(bindings) = args[0] else { return .nil }

        guard bindings.count > 0 else { return .nil }

        guard case let .atom(.string(name)) = bindings[0] else { return .nil }
        bindings = Array<SExpr>(bindings.dropFirst(1))
        let body: SExpr = args[1]

        environment[name] = .procedure({ args, environment in
          guard case let .list(args) = args else { return .nil }

          let names: [String] = bindings.compactMap {
            if case let .atom(.string(name)) = $0 {
              return name
            }
            // TODO: is this a free-variable which has already been bound?
            return nil
          }
          zip(names, args).forEach {
            environment.updateValue(.value($1), forKey: $0)
          }

          environment[name] = nil

          return body.evaluate(in: &environment)
        })

        return .nil
      }),
      Builtins.lambda.rawValue: .procedure({ args, environment in
        guard case let .list(args) = args, args.count == 2 else { return .nil }

        guard case let .list(bindings) = args[0] else { return .nil }
        let name: String = "$\(UInt32.random(in: 1000...9999))"
        let body: SExpr = args[1]

        environment[name] = .procedure({ args, environment in
          guard case let .list(args) = args else { return .nil }

          let names: [String] = bindings.compactMap {
            if case let .atom(.string(name)) = $0 {
              return name
            }
            // TODO: is this a free-variable which has already been bound?
            return nil
          }
          zip(names, args).forEach {
            environment.updateValue(.value($1), forKey: $0)
          }

          environment[name] = nil

          return body.evaluate(in: &environment)
        })

        return .atom(.string(name))
      }),
      Builtins.quote.rawValue: .procedure({ args, _ in
        guard case let .list(args) = args, args.count == 1 else { return .nil }
        return args[0]
      }),
    ]
  }
}
