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
  case presentThread(isPresented: Bool)
  case presentAdd(isPresented: Bool)
  case getPosts
  case didGetPosts(TaskResult<([ProfileModel], [PostModel])>)
  case deletePost(id: String)
  case didDeletePost(TaskResult<String>)
  
  // View Actions
  case add(AddAction)
  case stories(StoriesAction)
  case thread(ThreadAction)
}
