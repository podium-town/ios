//
//  ExploreReducer.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import ComposableArchitecture

let exploreReducer = Reducer<ExploreState, ExploreAction, AppEnvironment>.combine(
  profileReducer.optional().pullback(
    state: \.profileState,
    action: /ExploreAction.profile,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .getTopHashtags:
      return .task {
        await .didGetTopHashtags(TaskResult {
          try await API.getTopHashtags()
        })
      }
      
    case .didGetTopHashtags(.success(let hashtags)):
      state.hashtags = hashtags
      return .none
      
    case .didGetTopHashtags(.failure(let error)):
      return .none
      
    case .presentProfile(let isPresented, let profile):
      let fromProfile = state.profile
      state.isProfilePresented = isPresented
      if isPresented, let profile = profile {
        state.profileState = ProfileState(
          fromProfile: fromProfile,
          profile: profile
        )
      }
      return .none
      
    case .searchQueryChanged(let searchQuery):
      state.searchQuery = searchQuery.lowercased()
      return state.searchQuery.count > 2 ? Effect(value: .search) : .none
      
    case .search:
      let query = state.searchQuery
      return .task {
        await .didSearch(TaskResult {
          try await API.search(
            query: query
          )
        })
      }
      
    case .clearSearch:
      state.searchQuery = ""
      state.foundProfiles = []
      return .none
      
    case .didSearch(.success(let profiles)):
      state.foundProfiles = profiles.filter({ $0.id != state.profile.id})
      return .none
      
    case .didSearch(.failure(let error)):
      return .none
      
    case .follow(let id):
      state.pendingFollowRequests.append(id)
      let from = state.profile
      return .task {
        await .didFollow(TaskResult {
          try await API.follow(
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
          try await API.unFollow(
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
      
    case .profile(_):
      return .none
    }
  }
)
