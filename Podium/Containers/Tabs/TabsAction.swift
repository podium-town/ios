//
//  TabsAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Foundation

enum TabsAction {
  case initialize
  case getPosts
  case didGetPosts(TaskResult<([PostModel], [String: ProfileModel])>)
  case getStories
  case didGetStories(TaskResult<([String: [StoryModel]], [StoryUrlModel], [String: ProfileModel])>)
  case addPosts(posts: [PostModel], profiles: [String: ProfileModel])
  case addStories(stories: [String: [StoryModel]], urls: [StoryUrlModel])
  case onMenuClose
  case getProfile
  case didGetProfile(TaskResult<ProfileModel>)
  case prefetchStories
  case didPrefetchStories(TaskResult<[String: Data]>)
  case removeStories(stories: [String: [StoryModel]])
  
  // View Actions
  case home(HomeAction)
  case profile(ProfileAction)
  case add(AddAction)
  case explore(ExploreAction)
}
