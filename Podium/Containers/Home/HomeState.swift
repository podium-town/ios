//
//  HomeState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

struct HomeState: Equatable {
  var profile: ProfileModel
  var isStoriesPresented = false
  var isThreadPresented = false
  var isAddPresented = false
  var isLoadingRefreshable = false
  var profiles: [String: ProfileModel] = [:]
  var posts: [PostModel] = []
  
  // View States
  var add: AddState?
  var stories: StoriesState?
  var thread: ThreadState?
}
