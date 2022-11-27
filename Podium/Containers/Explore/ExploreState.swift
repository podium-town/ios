//
//  ExploreState.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

struct ExploreState: Equatable {
  var profile: ProfileModel
  var foundProfiles: [ProfileModel] = []
  var searchQuery = ""
  var pendingFollowRequests: [String] = []
  var isProfilePresented = false
  var hashtags: [HashtagModel] = []
  
  // View States
  var profileState: ProfileState?
}
