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
  case didGetPosts(TaskResult<[PostProfileModel]>)
  case getProfilePosts
  case didGetProfilePosts(TaskResult<[PostProfileModel]>)
  case getStories
  case didGetStories(TaskResult<([String: [StoryProfileModel]], [StoryUrlModel], [ProfileModel])>)
  case addPosts(posts: [PostProfileModel])
  case addStories(stories: [String: [StoryProfileModel]], urls: [StoryUrlModel], profiles: [ProfileModel])
  case onMenuClose
  case getProfile
  case didGetProfile(TaskResult<ProfileModel>)
  case prefetchStories
  case didPrefetchStories(TaskResult<[String: Data]>)
  case removeStories(stories: [String: [StoryModel]])
  
  // View Actions
  case home(HomeAction)
  case profile(ProfileAction)
  case explore(ExploreAction)
}
