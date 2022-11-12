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
      state.searchQuery = searchQuery.lowercased()
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
      
    case .clearSearch:
      state.searchQuery = ""
      state.profiles = []
      return .none
      
    case .didSearch(.success(let profiles)):
      state.profiles = profiles.filter({ $0.id != state.profile.id})
      return .none
      
    case .didSearch(.failure(let error)):
      return .none
      
    case .follow(let id):
      state.pendingFollowRequests.append(id)
      let from = state.profile
      return .task {
        await .didFollow(TaskResult {
          try await environment.api.follow(
            from: from,
            id: id
          )
        })
      }
      
    case .didFollow(.success((let from, let id))):
      state.pendingFollowRequests.removeAll(where: { $0 == id })
      if let encoded = from.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      return .none
      
    case .didFollow(.failure(let error)):
      return .none
      
    case .unFollow(let id):
      state.pendingFollowRequests.append(id)
      let from = state.profile
      return .task {
        await .didUnfollow(TaskResult {
          try await environment.api.unFollow(
            from: from,
            id: id
          )
        })
      }
      
    case .didUnfollow(.success((let from, let id))):
      state.pendingFollowRequests.removeAll(where: { $0 == id })
      if let encoded = from.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      return .none
      
    case .didUnfollow(.failure(let error)):
      return .none
    }
  }
)
