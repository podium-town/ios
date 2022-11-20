//
//  ProfileState.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

struct ProfileState: Equatable {
  var profile: ProfileModel
  var posts: [PostModel] = []
  var isPickerPresented = false
  var isLoadingRefreshable = false
  var isSettingsPresented = false
  var isEmpty = false
  var isSelf = false
  
  // View States
  var settingsState: SettingsState?
}
