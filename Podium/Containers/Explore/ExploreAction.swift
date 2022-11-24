//
//  ExploreAction.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import ComposableArchitecture

enum ExploreAction {
  case searchQueryChanged(String)
  case search
  case didSearch(TaskResult<[ProfileModel]>)
  case follow(String)
  case didFollow(TaskResult<(ProfileModel, String)>)
  case unFollow(String)
  case didUnfollow(TaskResult<(ProfileModel, String)>)
  case clearSearch
  case presentProfile(isPresented: Bool, profile: ProfileModel?)
  case getTopHashtags
  case didGetTopHashtags(TaskResult<[HashtagModel]>)
  
  // View Actions
  case profile(ProfileAction)
}
