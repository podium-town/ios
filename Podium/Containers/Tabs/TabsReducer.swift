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
    case .getProfile:
      let id = state.profile.id
      return .task {
        await .didGetProfile(TaskResult {
          try await API.getProfile(
            id: id
          )
        })
      }
      
    case .didGetProfile(.success(let profile)):
      state.profile = profile
      state.profileState.fromProfile = profile
      state.exploreState.profile = profile
      state.homeState.profile = profile
      environment.localStorage.removeObject(forKey: StorageKey.authVerificationID.rawValue)
      if let encoded = profile.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      return .none
      
    case .didGetProfile(.failure(let error)):
      return .none
      
    case .initialize:
//      if let posts = environment.localStorage.data(forKey: StorageKey.posts.rawValue),
//         let loadedPosts = try? JSONDecoder().decode([PostModel].self, from: posts) {
//        state.homeState.posts = loadedPosts
//      }
      return .none
      
    case .addPosts(let posts):
      state.homeState.posts.insert(contentsOf: posts, at: 0)
      if let encodedPosts = try? JSONEncoder().encode(state.homeState.posts) {
        environment.localStorage.set(encodedPosts, forKey: StorageKey.posts.rawValue)
      }
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
      
    case .home(.onMenuOpen):
      state.isMenuOpen = true
      return .none
      
    case .home(.thread(.openMenu)):
      state.isMenuOpen = true
      return .none
      
    case .onMenuClose:
      state.isMenuOpen = false
      return .none
      
    case .home(.profile(.didFollow(.success((let from, let id))))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.homeState.profile.following.append(id)
      state.profileState.fromProfile.following.append(id)
      state.homeState.profileState?.fromProfile.following.append(id)
      return Effect(value: .getPosts)
      
    case .home(.profile(.didUnfollow(.success((let from, let id))))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profileState?.fromProfile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect(value: .getPosts)
        
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
      
    case .profile(.onMenuOpen):
      state.isMenuOpen = true
      return .none
      
    case .profile(.didFollow(.success((let from, let id)))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.homeState.profile.following.append(id)
      state.profileState.fromProfile.following.append(id)
      return Effect(value: .getPosts)
      
    case .profile(.didUnfollow(.success((let from, let id)))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect(value: .getPosts)
      
    case .profile(_):
      return .none
      
    case .explore(.didFollow(.success((let from, let id)))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.homeState.profile.following.append(id)
      state.profileState.fromProfile.following.append(id)
      return Effect(value: .getPosts)
      
    case .explore(.didUnfollow(.success((let from, let id)))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect(value: .getPosts)
      
    case .explore(.profile(.didFollow(.success((let from, let id))))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.exploreState.profileState?.fromProfile.following.append(id)
      state.homeState.profile.following.append(id)
      state.profileState.fromProfile.following.append(id)
      return Effect(value: .getPosts)
      
    case .explore(.profile(.didUnfollow(.success((let from, let id))))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profileState?.fromProfile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect(value: .getPosts)
      
    case .explore(_):
      return .none
    }
  }
)
