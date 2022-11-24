//
//  HashtagModel.swift
//  Podium
//
//  Created by Michael Jach on 23/11/2022.
//

import Foundation

struct HashtagModel: Equatable, Identifiable {
  var id: String { hashtag }
  var hashtag: String
}

extension HashtagModel: Codable {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(
      HashtagModel.self,
      from: JSONSerialization.data(withJSONObject: dictionary)
    )
  }
  
  func encoded() -> Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}
