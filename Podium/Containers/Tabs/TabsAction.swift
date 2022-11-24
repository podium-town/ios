//
//  TabsAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

enum TabsAction {
  case initialize
  case getPosts
  case didGetPosts(TaskResult<[PostModel]>)
  case addPosts(posts: [PostModel])
  case onMenuClose
  case getProfile
  case didGetProfile(TaskResult<ProfileModel>)
  
  // View Actions
  case home(HomeAction)
  case profile(ProfileAction)
  case add(AddAction)
  case explore(ExploreAction)
}
