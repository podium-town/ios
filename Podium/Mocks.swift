//
//  Mocks.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation

struct Mocks {
  static var post = PostModel(
    id: "123",
    text: "You are viewing the README and repositories as a public user. You are viewing the README and repositories as a public user.",
    ownerId: "456",
    createdAt: 123
  )
  static var profile = ProfileModel(
    id: "0000",
    username: "username",
    createdAt: 12312321
  )
}
