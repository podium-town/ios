//
//  TabsAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

enum TabsAction {
  case getPosts
  case didGetPosts(TaskResult<[PostModel]>)
  
  // View Actions
  case home(HomeAction)
  case profile(ProfileAction)
  case add(AddAction)
  case explore(ExploreAction)
}
