//
//  StoryModel.swift
//  Podium
//
//  Created by Michael Jach on 24/11/2022.
//

import Foundation
import FirebaseFirestore

struct StoryModel: Equatable, Identifiable, Codable {
  var id: String
  var url: String
  var fileId: String
  var ownerId: String
  var createdAt: Int64
  var expireAt: Timestamp
  var seenBy: [SeenByModel]
}

struct SeenByModel: Equatable, Identifiable, Codable {
  var id: String
  var username: String
  var avatarBase64: String?
  var hasLiked: Bool
}
