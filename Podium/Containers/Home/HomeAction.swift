//
//  HomeAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Foundation

enum HomeAction {
  case initialize
  case presentStories(isPresented: Bool, profile: ProfileModel?)
  case presentThread(isPresented: Bool, post: PostModel?)
  case presentAdd(isPresented: Bool)
  case presentProfile(isPresented: Bool, profile: ProfileModel?)
  case presentMedia(isPresented: Bool, post: PostModel?)
  case getPosts
  case didGetPosts(TaskResult<[PostModel]>)
  case deletePost(post: PostModel)
  case didDeletePost(TaskResult<String>)
  case reportPost(post: PostModel)
  case didReportPost(TaskResult<String>)
  case dismissBanner
  case onMenuOpen
  case getStories
  case didGetStories(TaskResult<([String: [StoryModel]], [String])>)
  case prefetchStories
  case didPrefetchStories(TaskResult<[String: Data]>)
  
  // View Actions
  case add(AddAction)
  case stories(StoriesAction)
  case thread(ThreadAction)
  case profile(ProfileAction)
  case media(MediaAction)
}
