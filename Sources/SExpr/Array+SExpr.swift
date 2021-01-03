//
// Copyright © 2021 Saleem Abdulrasool <compnerd@compnerd.org>
// All Rights Reserved.
//
// SPDX-License-Identifier: BSD-3-Clause
//

extension Array {
  mutating func popFront() -> Element? {
    guard self.count > 0 else { return nil }
    let element = self[0]
    self = Self(self.suffix(from: 1))
    return element
  }
}
