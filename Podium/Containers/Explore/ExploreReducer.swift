//
//  ExploreReducer.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import ComposableArchitecture
import Foundation

struct Explore: ReducerProtocol {
  typealias State = ExploreState
  typealias Action = ExploreAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .presentHashtag(let isPresented, let hashtag):
        state.isHashtagPresented = isPresented
        if isPresented, let hashtag = hashtag {
          state.hashtagState = HashtagState(
            profile: state.profile,
            hashtag: hashtag
          )
        }
        return .none
        
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
        state.foundProfiles = profiles
          .filter({ $0.id != state.profile.id})
          .filter({ !state.profile.blockedProfiles.contains($0.id) })
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
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
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
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        return .none
        
      case .didUnfollow(.failure(let error)):
        return .none
        
      case .profile(_):
        return .none
        
      case .hashtag(_):
        return .none
      }
    }
    .ifLet(\.profileState, action: /Action.profile) {
      Profile()
    }
    .ifLet(\.hashtagState, action: /Action.hashtag) {
      Hashtag()
    }
  }
}
