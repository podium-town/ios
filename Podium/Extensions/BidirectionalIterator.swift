//
//  BidirectionalIterator.swift
//  Podium
//
//  Created by Michael Jach on 27/11/2022.
//

struct BidirectionalIterator<B, I> where B: BidirectionalCollection, B.Index == I {
  
  let collection: B
  
  var lastGivenIndex: I? = nil
  
  init(collection: B) {
    self.collection = collection
  }
  
  mutating func next() -> B.Iterator.Element? {
    guard let lastGivenIndex = lastGivenIndex else {
      self.lastGivenIndex = collection.startIndex
      return collection.first
    }
    
    if lastGivenIndex >= collection.index(before: collection.endIndex) {
      self.lastGivenIndex = collection.endIndex
      return nil
    }
    
    self.lastGivenIndex = collection.index(after: lastGivenIndex)
    return self.lastGivenIndex.map({ collection[$0] })
  }
  
  mutating func previous() -> B.Iterator.Element? {
    guard let lastGivenIndex = lastGivenIndex else {
      return nil
    }
    
    if lastGivenIndex <= collection.startIndex {
      self.lastGivenIndex = collection.startIndex
      return nil
    }
    
    self.lastGivenIndex = collection.index(before: lastGivenIndex)
    return self.lastGivenIndex.map({ collection[$0] })
  }
  
  mutating func last() -> B.Iterator.Element? {
    self.lastGivenIndex = collection.index(before: collection.endIndex)
    return self.lastGivenIndex.map({ collection[$0] })
  }
  
  mutating func at(index: I) -> B.Iterator.Element? {
    self.lastGivenIndex = index
    return self.lastGivenIndex.map({ collection[$0] })
  }
}

extension BidirectionalCollection {
  func makeBidirectionalIterator() -> BidirectionalIterator<Self, Index> {
    return BidirectionalIterator<Self, Index>(collection: self)
  }
}

extension BidirectionalIterator: Equatable {
  static func == (lhs: BidirectionalIterator<B, I>, rhs: BidirectionalIterator<B, I>) -> Bool {
    return true
  }
}
