//
//  TabsReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation

let tabsReducer = Reducer<TabsState, TabsAction, AppEnvironment>.combine(
  homeReducer.pullback(
    state: \.homeState,
    action: /TabsAction.home,
    environment: { $0 }
  ),
  profileReducer.pullback(
    state: \.profileState,
    action: /TabsAction.profile,
    environment: { $0 }
  ),
  addReducer.pullback(
    state: \.addState,
    action: /TabsAction.add,
    environment: { $0 }
  ),
  exploreReducer.pullback(
    state: \.exploreState,
    action: /TabsAction.explore,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .addPosts(let posts):
      state.homeState.posts.insert(contentsOf: posts.filter({ $0.ownerId != state.profile.id }), at: 0)
      return .none
      
    case .getPosts:
      if let posts = environment.localStorage.data(forKey: StorageKey.posts.rawValue),
         let loadedPosts = try? JSONDecoder().decode([PostModel].self, from: posts) {
        state.homeState.posts = loadedPosts
        state.homeState.isLoadingRefreshable = true
      }
      let followingIds = state.profile.following
      return .task {
        await .didGetPosts(TaskResult {
          try await API.getPostsProfiles(
            ids: followingIds
          )
        })
      }
      
    case .didGetPosts(.success(let posts)):
      state.homeState.isLoadingRefreshable = false
      state.homeState.posts = posts
      if let encodedPosts = try? JSONEncoder().encode(state.homeState.posts) {
        environment.localStorage.set(encodedPosts, forKey: StorageKey.posts.rawValue)
      }
      state.homeState.isEmpty = posts.count == 0
      return .none
      
    case .didGetPosts(.failure(let error)):
      state.homeState.isLoadingRefreshable = false
      state.homeState.isEmpty = state.homeState.posts.count == 0
      return .none
        
    case .home(_):
      return .none
      
    case .add(.didAddPost(.success(let post))):
      state.profileState.posts.append(post)
      return .none
      
    case .add(_):
      return .none
      
    case .profile(.changeAvatar(let uiImage)):
      let avatar = uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: 300, height: 300)).jpegData(compressionQuality: 0.5)
      state.profile.avatarData = avatar
      state.profileState.profile.avatarData = avatar
      state.exploreState.profile.avatarData = avatar
      state.homeState.profile.avatarData = avatar
      if let encoded = state.profile.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      return .none
      
    case .profile(_):
      return .none
      
    case .explore(.didFollow(.success((let from, let id)))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.homeState.profile.following.append(id)
      return Effect(value: .getPosts)
      
    case .explore(.didUnfollow(.success((let from, let id)))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      return Effect(value: .getPosts)
      
    case .explore(_):
      return .none
    }
  }
)
