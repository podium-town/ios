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
    case .prefetchStories:
      let index = min(state.urls.count, 5)
      let fileUrls = Array(state.urls.sorted(by: { $0.createdAt > $1.createdAt }).prefix(upTo: index))
      return .task {
        await .didPrefetchStories(TaskResult {
          try await API.prefetchStories(
            fileUrls: fileUrls.map({ $0.url })
          )
        })
      }
      
    case .didPrefetchStories(.success(let results)):
      for result in results {
        state.homeState.storiesState?.loadedMedia[result.key] = result.value
        state.homeState.storiesState?.urls.removeAll(where: { $0.url == result.key })
      }
      return .none
      
    case .didPrefetchStories(.failure(let error)):
      return .none
      
    case .getProfile:
      let id = state.profile.id
      return .task {
        await .didGetProfile(TaskResult {
          try await API.getProfile(
            id: id
          )
        })
      }
      
    case .removeStories(let stories):
      for (profileId, story) in stories {
        story.forEach { st in
          state.homeState.stories[profileId]?.removeAll(where: { $0.story.id == st.id })
          state.homeState.storiesState?.stories[profileId]?.removeAll(where: { $0.story.id == st.id })
          state.urls.removeAll(where: { $0.url == st.url})
          state.homeState.storiesState?.urls.removeAll(where: { $0.url == st.url})
        }
      }
      return Effect(value: .prefetchStories)
      
    case .addStories(let stories, let urls):
      var defaultStories = stories
      if !defaultStories.contains(where: { $0.key == state.profile.id }) {
        defaultStories[state.profile.id] = []
      }
      
      state.homeState.stories.merge(defaultStories, uniquingKeysWith: +)
      state.homeState.storiesState?.stories.merge(defaultStories, uniquingKeysWith: +)
      state.urls.append(contentsOf: urls)
      state.homeState.storiesState?.urls.append(contentsOf: urls)
      return Effect(value: .prefetchStories)
      
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
      state.homeState.storiesState = StoriesState(
        profile: state.profile,
        stories: [:]
      )
      return Effect(value: .getProfilePosts)
      
    case .addPosts(let posts):
      state.homeState.posts.insert(contentsOf: posts.sorted(by: { $0.post.createdAt > $1.post.createdAt }), at: 0)
      return .none
      
    case .getProfilePosts:
      let id = state.profile.id
      return .task {
        await .didGetProfilePosts(TaskResult {
          try await API.getPosts(
            followingIds: [id]
          )
        })
      }
      
    case .didGetProfilePosts(.success(let posts)):
      state.profileState.posts = posts
      return .none
      
    case .didGetProfilePosts(.failure(let error)):
      state.homeState.bannerData = BannerData(
        title: "Error",
        detail: "Error while loading posts.",
        type: .error
      )
      return .none
      
    case .getStories:
      let followingIds = state.profile.following
      return .task {
        await .didGetStories(TaskResult {
          try await API.getStories(
            ids: followingIds
          )
        })
      }
      
    case .didGetStories(.success((let stories, let urls))):
      var defaultStories = stories
            
      if !defaultStories.contains(where: { $0.key == state.profile.id }) {
        defaultStories[state.profile.id] = []
      }
      
      state.homeState.stories = defaultStories
      state.homeState.storiesState?.stories = defaultStories
      state.urls = urls
      state.homeState.storiesState?.urls = urls
      return Effect(value: .prefetchStories)
      
    case .didGetStories(.failure(let error)):
      state.homeState.bannerData = BannerData(
        title: "Error",
        detail: "Error while loading stories.",
        type: .error
      )
      return .none
      
    case .getPosts:
      let followingIds = state.profile.following
      return .task {
        await .didGetPosts(TaskResult {
          try await API.getPosts(
            followingIds: followingIds
          )
        })
      }
      
    case .didGetPosts(.success(let posts)):
      state.homeState.isLoadingRefreshable = false
      state.homeState.posts = posts
      state.homeState.isEmpty = posts.count == 0
      return .none
      
    case .didGetPosts(.failure(let error)):
      state.homeState.isLoadingRefreshable = false
      state.homeState.isEmpty = state.homeState.posts.count == 0
      state.homeState.bannerData = BannerData(
        title: "Error",
        detail: "Error while loading posts.",
        type: .error
      )
      return .none
      
    case .home(.getPosts):
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
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
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
    case .home(.profile(.didUnfollow(.success((let from, let id))))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profileState?.fromProfile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
        
    case .home(_):
      return .none
      
    case .add(.didAddPost(.success(let post))):
      state.profileState.posts?.append(post)
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
      return Effect(value: .getStories)
      
    case .profile(.didUnfollow(.success((let from, let id)))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
    case .profile(_):
      return .none
      
    case .explore(.didFollow(.success((let from, let id)))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.homeState.profile.following.append(id)
      state.profileState.fromProfile.following.append(id)
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
    case .explore(.didUnfollow(.success((let from, let id)))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
    case .explore(.profile(.didFollow(.success((let from, let id))))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.exploreState.profileState?.fromProfile.following.append(id)
      state.homeState.profile.following.append(id)
      state.profileState.fromProfile.following.append(id)
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
    case .explore(.profile(.didUnfollow(.success((let from, let id))))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profileState?.fromProfile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      state.profileState.fromProfile.following.removeAll(where: { $0 == id })
      return Effect.merge([
        Effect(value: .getPosts),
        Effect(value: .getStories)
      ])
      
    case .explore(_):
      return .none
    }
  }
)
