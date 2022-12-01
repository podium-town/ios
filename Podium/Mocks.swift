//
//  Mocks.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation
import UIKit
import FirebaseFirestore

struct Mocks {
  static var post = PostModel(
    id: "123",
    text: "You are viewing the #README and repositories as a public user. You are viewing the README and repositories as a public #user.",
    ownerId: "456",
    createdAt: 123,
    images: [
      PostImage(
        id: "", url: "preview"
      ),
      PostImage(
        id: "", url: "preview"
      ),
      PostImage(
        id: "", url: "preview"
      )
    ]
  )
  static var postProfile = PostProfileModel(
    id: "123",
    post: Mocks.post,
    profile: Mocks.profile
  )
  static var postSimple = PostModel(
    id: "123",
    text: "You are viewing the README and repositories as a public user. You are viewing the README and repositories as a public user.",
    ownerId: "456",
    createdAt: 123
  )
  static var comment = PostModel(
    id: "1123",
    text: "I'm a test comment.",
    ownerId: "456",
    createdAt: 123
  )
  static var profile = ProfileModel(
    id: "456",
    username: "username_long",
    createdAt: 12312321,
    hasNewStories: true
  )
  static var profile2 = ProfileModel(
    id: "4563",
    username: "username_long",
    createdAt: 12312321
  )
  static var story = StoryModel(
    id: "0x0",
    url: "sadsada",
    fileId: "xxx1",
    ownerId: "456",
    createdAt: 123,
    expireAt: Timestamp(),
    seenBy: [],
    likedBy: []
  )
  static var storyProfile = StoryProfileModel(
    story: story,
    profile: Mocks.profile
  )
}
