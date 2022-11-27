//
//  ProfileState.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

struct ProfileState: Equatable {
  var isSelf = false
  var isLoading = false
  var fromProfile: ProfileModel
  var profile: ProfileModel
  var posts: [PostProfileModel]?
  var isPickerPresented = false
  var isLoadingRefreshable = false
  var isSettingsPresented = false
  var isThreadPresented = false
  var isMediaPresented = false
  var isEmpty = false
  var isPendingFollowing = false
  var bannerData: BannerData?
  
  // View States
  var settingsState: SettingsState?
  var threadState: ThreadState?
  var mediaState: MediaState?
}
