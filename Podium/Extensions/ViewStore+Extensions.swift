//
//  ViewStore+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import SwiftUI
import ComposableArchitecture
import Combine

extension ViewStore {
  func send(_ action: Action, `while` isInFlight: @escaping (State) -> Bool) async {
    self.send(action)
    await withUnsafeContinuation { (continuation: UnsafeContinuation<Void, Never>) in
      var cancellable: Cancellable?
      cancellable = self.publisher
        .filter { !isInFlight($0) }
        .prefix(1)
        .sink { _ in
          continuation.resume(returning: ())
          _ = cancellable
        }
    }
  }
}
