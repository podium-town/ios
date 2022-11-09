//
//  HomeState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

struct HomeState: Equatable {
  var isStoriesPresented = false
  var isThreadPresented = false
  
  // View States
  var stories: StoriesState?
  var thread: ThreadState?
}
