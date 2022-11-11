//
//  ExploreReducer.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import ComposableArchitecture

let exploreReducer = Reducer<ExploreState, ExploreAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .searchQueryChanged(let searchQuery):
      state.searchQuery = searchQuery
      return state.searchQuery.count > 2 ? Effect(value: .search) : .none
      
    case .search:
      let query = state.searchQuery
      return .task {
        await .didSearch(TaskResult {
          try await environment.api.search(
            query: query
          )
        })
      }
      
    case .didSearch(.success(let profiles)):
      state.profiles = profiles
      return .none
      
    case .didSearch(.failure(let error)):
      return .none
      
    case .follow(let id):
      state.pendingFollowRequests.append(id)
      return .none
      
    case .didFollow(.success(let id)):
      state.pendingFollowRequests.removeAll(where: { $0 == id })
      return .none
      
    case .didFollow(.failure(let error)):
      return .none
    }
  }
)
