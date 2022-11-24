//
//  HomeAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

enum HomeAction {
  case initialize
  case presentStories(isPresented: Bool)
  case presentThread(isPresented: Bool, post: PostModel?)
  case presentAdd(isPresented: Bool)
  case presentProfile(isPresented: Bool, profile: ProfileModel?)
  case presentMedia(isPresented: Bool, post: PostModel?)
  case getPosts
  case didGetPosts(TaskResult<[PostModel]>)
  case deletePost(post: PostModel)
  case didDeletePost(TaskResult<String>)
  case dismissBanner
  case onMenuOpen
  
  // View Actions
  case add(AddAction)
  case stories(StoriesAction)
  case thread(ThreadAction)
  case profile(ProfileAction)
  case media(MediaAction)
}
