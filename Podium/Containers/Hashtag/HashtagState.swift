//
//  HashtagState.swift
//  Podium
//
//  Created by Michael Jach on 02/12/2022.
//

struct HashtagState: Equatable {
  var profile: ProfileModel
  var hashtag: String
  var posts: [PostProfileModel] = []
  var isLoadingRefreshable = false
  var isMediaPresented = false
  var isProfilePresented = false
  var isThreadPresented = false
  
  // View States
  var mediaState: MediaState?
  var profileState: ProfileState?
  var threadState: ThreadState?
}
