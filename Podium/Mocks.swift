//
//  Mocks.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation
import UIKit

struct Mocks {
  static var post = PostModel(
    id: "123",
    text: "You are viewing the #README and repositories as a public user. You are viewing the README and repositories as a public #user.",
    ownerId: "456",
    createdAt: 123,
    images: ["ID1", "id2", "od3"],
    profile: Mocks.profile,
    isLoading: true
  )
  static var postSimple = PostModel(
    id: "123",
    text: "You are viewing the README and repositories as a public user. You are viewing the README and repositories as a public user.",
    ownerId: "456",
    createdAt: 123,
    profile: Mocks.profile
  )
  static var comment = PostModel(
    id: "1123",
    text: "I'm a test comment.",
    ownerId: "456",
    createdAt: 123,
    postId: "123",
    profile: Mocks.profile
  )
  static var profile = ProfileModel(
    id: "456",
    username: "username_long",
    createdAt: 12312321
  )
  static var profile2 = ProfileModel(
    id: "4563",
    username: "username_long",
    createdAt: 12312321
  )
}
