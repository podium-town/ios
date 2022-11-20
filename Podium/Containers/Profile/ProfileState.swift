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
  var isEmpty = false
}
