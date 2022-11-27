//
//  HashtagModel.swift
//  Podium
//
//  Created by Michael Jach on 23/11/2022.
//

import Foundation

struct HashtagModel: Equatable, Identifiable, Codable {
  var id: String { hashtag }
  var hashtag: String
  var createdAt: Int64
  var posts: [String]
}
