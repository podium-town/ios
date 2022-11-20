//
//  PostModel.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation

struct PostModel: Equatable, Identifiable {
  var id: String
  var text: String
  var ownerId: String
  var createdAt: Int64
  var images: [String] = []
  var postId: String?
  var profile: ProfileModel?
}

extension PostModel: Codable {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(
      PostModel.self,
      from: JSONSerialization.data(withJSONObject: dictionary)
    )
  }
  
  func encoded() -> Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}
