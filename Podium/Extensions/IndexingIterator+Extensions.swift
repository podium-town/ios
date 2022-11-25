//
//  IndexingIterator+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 24/11/2022.
//

extension IndexingIterator: Equatable {
  public static func == (lhs: IndexingIterator<Elements>, rhs: IndexingIterator<Elements>) -> Bool {
    return true
  }
}
