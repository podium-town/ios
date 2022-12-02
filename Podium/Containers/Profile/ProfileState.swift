//
//  ProfileState.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import Foundation

struct ProfileState: Equatable {
  var isLoading = false
  var fromProfile: ProfileModel
  var profile: ProfileModel
  var isPickerPresented = false
  var isSettingsPresented = false
  var isMediaPresented = false
  var isThreadPresented = false
  var isEmpty = false
  var isPendingFollowing = false
  var bannerData: BannerData?
  var posts: [PostProfileModel] = []
  
  // View States
  var settingsState: SettingsState?
  var mediaState: MediaState?
  var threadState: ThreadState?
}
