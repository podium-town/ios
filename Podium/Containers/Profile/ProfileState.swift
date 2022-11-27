//
//  ProfileState.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

struct ProfileState: Equatable {
  var fromProfile: ProfileModel
  var profile: ProfileModel
  var profiles: [String: ProfileModel]
  var posts: [PostModel] = []
  var isPickerPresented = false
  var isLoadingRefreshable = false
  var isSettingsPresented = false
  var isThreadPresented = false
  var isMediaPresented = false
  var isEmpty = false
  var isLoading = false
  var isPendingFollowing = false
  var bannerData: BannerData?
  
  // View States
  var settingsState: SettingsState?
  var threadState: ThreadState?
  var mediaState: MediaState?
}
