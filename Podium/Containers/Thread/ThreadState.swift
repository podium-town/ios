//
//  ThreadState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import FirebaseFirestore

struct ThreadState: Equatable {
  var fromProfile: ProfileModel
  var profile: ProfileModel?
  var profiles: [String: ProfileModel]
  var post: PostModel
  var text = ""
  var isSendDisabled = true
  var comments: [PostModel] = []
  var isLoading = false
  var isMediaPresented = false
  
  // View States
  var mediaState: MediaState?
}
