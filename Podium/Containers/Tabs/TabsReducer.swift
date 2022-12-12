//
//  TabsReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation

struct Tabs: ReducerProtocol {
  typealias State = TabsState
  typealias Action = TabsAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .profile(.onMenuOpen),
          .home(.profile(.onMenuOpen)),
          .explore(.profile(.onMenuOpen)),
          .explore(.hashtag(.onMenuOpen)),
          .home(.onMenuOpen):
        state.isMenuOpen = true
        return .none
        
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
        
      case .didPrefetchStories(.failure(_)):
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
            if let st = state.homeState.stories[profileId] {
              if st.isEmpty {
                state.homeState.profiles.removeAll(where: { $0.id == profileId })
              }
            }
          }
        }
        return Effect(value: .prefetchStories)
        
      case .addStories(let stories, let urls, let profiles):
        state.homeState.isStoriesLoading = false
        state.homeState.stories.merge(stories, uniquingKeysWith: +)
        state.homeState.storiesState?.stories.merge(stories, uniquingKeysWith: +)
        
        for profileToAdd in profiles {
          if state.homeState.profiles.contains(where: { $0.id == profileToAdd.id }) {
            state.homeState.profiles.removeAll(where: { $0.id == profileToAdd.id })
          }
          state.homeState.profiles.append(profileToAdd)
        }
        
        let sortedProfiles = state.homeState.stories
          .sorted(by: { $0.value.last!.story.createdAt > $1.value.last!.story.createdAt })
          .compactMap({ story in
            return state.homeState.profiles.first(where: { profile in
              return profile.id == story.key
            })
          })
        
        state.homeState.profiles = sortedProfiles
        state.homeState.profiles = state.homeState.profiles.filter({ $0.id != state.profile.id })
        state.homeState.profiles.insert(state.profile, at: 0)
        
        state.urls.append(contentsOf: urls)
        state.homeState.storiesState?.urls.append(contentsOf: urls)
        return Effect(value: .prefetchStories)
        
      case .didGetProfile(.success(let profile)):
        state.profile = profile
        state.profileState.fromProfile = profile
        state.exploreState.profile = profile
        state.homeState.profile = profile
        UserDefaults.standard.removeObject(forKey: StorageKey.authVerificationID.rawValue)
        if let encoded = profile.encoded() {
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        return Effect(value: .getProfilePosts)
        
      case .didGetProfile(.failure(_)):
        return .none
        
      case .initialize:
        state.homeState.isStoriesLoading = true
        state.homeState.storiesState = StoriesState(
          profile: state.profile,
          stories: [:]
        )
        return .none
        
      case .addPosts(let posts):
        state.homeState.posts.insert(contentsOf: posts.filter({ post in
          return !state.profile.blockedPosts.contains(where: { $0 == post.post.id })
        }).sorted(by: { $0.post.createdAt > $1.post.createdAt }), at: 0)
        return .none
        
      case .getPosts:
        let blockedProfiles = state.profile.blockedProfiles
        let followingIds = state.profile.following.filter({ !blockedProfiles.contains($0) })
        return .task {
          await .didGetPosts(TaskResult {
            try await API.getPosts(
              followingIds: followingIds
            )
          })
        }
        
      case .didGetPosts(.success(let posts)):
        state.homeState.isLoadingRefreshable = false
        let added = posts
          .filter({ post in
            return !state.profile.blockedPosts.contains(where: { $0 == post.post.id })
          })
        state.homeState.posts = added
        state.homeState.isEmpty = added.isEmpty
        return Effect(value: .getStories)
        
      case .didGetPosts(.failure(_)):
        state.homeState.isLoadingRefreshable = false
        state.homeState.bannerData = BannerData(
          title: "Error",
          detail: "Error while loading posts.",
          type: .error
        )
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
        
      case .didGetProfilePosts(.failure(_)):
        state.homeState.bannerData = BannerData(
          title: "Error",
          detail: "Error while loading posts.",
          type: .error
        )
        return .none
        
      case .getStories:
        let followingIds = state.profile.following
        let profileId = state.profile.id
        let blocked = state.profile.blockedProfiles
        return .task {
          await .didGetStories(TaskResult {
            try await API.getStories(
              ids: followingIds.filter({ !blocked.contains($0) }),
              profileId: profileId
            )
          })
        }
        
      case .didGetStories(.success((let stories, let urls, let profiles))):
        state.homeState.profiles = profiles
        let sortedProfiles = state.homeState.stories
          .sorted(by: { $0.value.last!.story.createdAt > $1.value.last!.story.createdAt })
          .compactMap({ story in
            return state.homeState.profiles.first(where: { profile in
              return profile.id == story.key
            })
          })
        
        state.homeState.profiles = sortedProfiles
        state.homeState.profiles = state.homeState.profiles.filter({ $0.id != state.profile.id })
        state.homeState.profiles.insert(state.profile, at: 0)
        state.homeState.stories = stories
        state.homeState.storiesState?.stories = stories
        state.urls = urls
        state.homeState.storiesState?.urls = urls
        return Effect(value: .prefetchStories)
        
      case .didGetStories(.failure(_)):
        state.homeState.bannerData = BannerData(
          title: "Error",
          detail: "Error while loading stories.",
          type: .error
        )
        return .none
        
      case .onMenuClose:
        state.isMenuOpen = false
        return .none
        
      case .home(.profile(.didBlockPost(.success(let post)))),
          .explore(.profile(.didBlockPost(.success(let post)))),
          .explore(.hashtag(.profile(.didBlockPost(.success(let post))))),
          .home(.didBlockPost(.success(let post))):
        state.profile.blockedPosts.append(post.id)
        state.homeState.profile.blockedPosts.append(post.id)
        state.exploreState.profile.blockedPosts.append(post.id)
        state.profileState.profile.blockedPosts.append(post.id)
        return .none
        
      case .home(.profile(.didBlockProfile(.success(let profile)))),
          .explore(.profile(.didBlockProfile(.success(let profile)))),
          .explore(.hashtag(.profile(.didBlockProfile(.success(let profile))))),
          .home(.didBlockProfile(.success(let profile))):
        state.profile.blockedProfiles.append(profile.id)
        state.homeState.profile.blockedProfiles.append(profile.id)
        state.exploreState.profile.blockedProfiles.append(profile.id)
        state.profileState.profile.blockedProfiles.append(profile.id)
        return .none
        
      case .home(.profile(.didUnfollow(.success((_, let id))))),
          .explore(.profile(.didUnfollow(.success((_, let id))))),
          .explore(.didUnfollow(.success((_, let id)))):
        state.profile.following.removeAll(where: { $0 == id })
        state.homeState.profileState?.fromProfile.following.removeAll(where: { $0 == id })
        state.homeState.profile.following.removeAll(where: { $0 == id })
        state.exploreState.profile.following.removeAll(where: { $0 == id })
        state.profileState.profile.following.removeAll(where: { $0 == id })
        return Effect.merge([
          Effect(value: .getPosts)
        ])
        
      case .home(.profile(.didFollow(.success((_, let id))))),
          .explore(.profile(.didFollow(.success((_, let id))))),
          .explore(.didFollow(.success((_, let id)))):
        if !state.profile.following.contains(id) {
          state.homeState.profileState?.fromProfile.following.append(id)
          state.profile.following.append(id)
          state.homeState.profile.following.append(id)
          state.exploreState.profile.following.append(id)
          state.profileState.profile.following.append(id)
        }
        return Effect.merge([
          Effect(value: .getPosts)
        ])
        
      case .home(.getPosts):
        return Effect.merge([
          Effect(value: .getPosts)
        ])
        
      case .home(_):
        return .none
        
      case .profile(.changeAvatar(let uiImage)):
        let avatar = uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: 300, height: 300)).jpegData(compressionQuality: 0.5)
        state.profile.avatarData = avatar
        state.profileState.profile.avatarData = avatar
        state.exploreState.profile.avatarData = avatar
        state.homeState.profile.avatarData = avatar
        if let encoded = state.profile.encoded() {
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        return .none
        
      case .profile(_):
        return .none
        
      case .explore(_):
        return .none
      }
    }
    
    Scope(state: \.homeState, action: /Action.home) {
      Home()
    }
    
    Scope(state: \.exploreState, action: /Action.explore) {
      Explore()
    }
    
    Scope(state: \.profileState, action: /Action.profile) {
      Profile()
    }
  }
}
