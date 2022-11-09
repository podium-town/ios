//
//  HomeReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine

let homeReducer = Reducer<HomeState, HomeAction, AppEnvironment>.combine(
  storiesReducer.optional().pullback(
    state: \.stories,
    action: /HomeAction.stories,
    environment: { $0 }
  ),
  threadReducer.optional().pullback(
    state: \.thread,
    action: /HomeAction.thread,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .initialize:
      state.stories = StoriesState()
      return .none
      
    case .presentStories(let isPresented):
      state.isStoriesPresented = isPresented
      if isPresented {
        state.stories = StoriesState()
      }
      return .none
      
    case .presentThread(let isPresented):
      state.isThreadPresented = isPresented
      if isPresented {
        state.thread = ThreadState()
      }
      return .none
      
    case .stories(_):
      return .none
    }
  }
)
