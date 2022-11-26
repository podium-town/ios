//
//  StoryModel.swift
//  Podium
//
//  Created by Michael Jach on 24/11/2022.
//

import Foundation

struct StoryModel: Equatable, Identifiable {
  var id: String
  var url: String
  var ownerId: String
  var createdAt: Int64
  var profile: ProfileModel?
  var data: Data?
  var seenBy: [String]? = []
}

extension StoryModel: Codable {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(
      StoryModel.self,
      from: JSONSerialization.data(withJSONObject: dictionary)
    )
  }
  
  func encoded() -> Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}
