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
  case getProfilePosts
  case didGetProfilePosts(TaskResult<[PostProfileModel]>)
  case getStories
  case didGetStories(TaskResult<([String: [StoryProfileModel]], [StoryUrlModel])>)
  case addPosts(posts: [PostProfileModel])
  case addStories(stories: [String: [StoryProfileModel]], urls: [StoryUrlModel])
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
