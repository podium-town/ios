//
//  ThreadState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

struct ThreadState: Equatable {
  var profile: ProfileModel
  var post: PostModel?
  var text = ""
  var isSendDisabled = true
  var comments: [PostModel] = []
}
