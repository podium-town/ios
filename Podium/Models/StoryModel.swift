//
//  StoryModel.swift
//  Podium
//
//  Created by Michael Jach on 24/11/2022.
//

import Foundation

struct StoryModel: Equatable, Identifiable, Codable {
  var id: String
  var url: String
  var fileId: String
  var ownerId: String
  var createdAt: Int64
}
