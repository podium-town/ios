//
//  ThreadState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import FirebaseFirestore

struct ThreadState: Equatable {
  var fromProfile: ProfileModel
  var post: PostProfileModel
  var text = ""
  var isSendDisabled = true
  var comments: [PostProfileModel] = []
  var isLoading = false
  var isMediaPresented = false
  
  // View States
  var mediaState: MediaState?
}
