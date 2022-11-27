//
//  PostModel.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation
import UIKit

struct PostModel: Equatable, Identifiable, Codable {
  var id: String
  var text: String
  var ownerId: String
  var createdAt: Int64
  var images: [PostImage] = []
}
