//
//  ProfileReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import Foundation

struct Profile: ReducerProtocol {
  typealias State = ProfileState
  typealias Action = ProfileAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .getPosts:
        let id = state.profile.id
        return .task {
          await .didGetPosts(TaskResult {
            try await API.getPosts(followingIds: [id])
          })
        }
        
      case .didGetPosts(.success(let posts)):
        state.posts = posts
        return .none
        
      case .didGetPosts(.failure(_)):
        return .none
        
      case .follow:
        state.isPendingFollowing = true
        let from = state.fromProfile
        let to = state.profile
        return .task {
          await .didFollow(TaskResult {
            try await API.follow(
              from: from,
              id: to.id
            )
          })
        }
        
      case .didFollow(.success((let from, let id))):
        state.isPendingFollowing = false
        if let encoded = from.encoded() {
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        return .none
        
      case .didFollow(.failure(let error)):
        state.isPendingFollowing = false
        return .none
        
      case .unfollow:
        state.isPendingFollowing = true
        let from = state.fromProfile
        let to = state.profile
        return .task {
          await .didUnfollow(TaskResult {
            try await API.unFollow(
              from: from,
              id: to.id
            )
          })
        }
        
      case .didUnfollow(.success((let from, let id))):
        state.isPendingFollowing = false
        if let encoded = from.encoded() {
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        return .none
        
      case .didUnfollow(.failure(let error)):
        state.isPendingFollowing = false
        return .none
        
      case .onMenuOpen:
        return .none
        
      case .dismissBanner:
        state.bannerData = nil
        return .none
        
      case .presentPicker(let isPresented):
        state.isPickerPresented = isPresented
        return .none
        
      case .presentSettings(let isPresented):
        state.isSettingsPresented = isPresented
        if isPresented {
          state.settingsState = SettingsState(
            profile: state.profile
          )
        }
        return .none
        
      case .presentMedia(let isPresented, let post, let loadedImages):
        state.isMediaPresented = isPresented
        if isPresented, let post = post {
          state.mediaState = MediaState(
            post: post,
            loadedImages: loadedImages
          )
        }
        return .none
        
      case .presentThread(let isPresented, let post):
        state.isThreadPresented = isPresented
        if isPresented, let post = post {
          state.threadState = ThreadState(
            fromProfile: state.fromProfile,
            post: post
          )
        }
        return .none
        
      case .changeAvatar(let uiImage):
        let profileId = state.profile.id
        Task {
          try await API.changeAvatar(
            profileId: profileId,
            uiImage: uiImage
          )
        }
        return .none
        
      case .deletePost(let post):
        return .task {
          await .didDeletePost(TaskResult {
            try await API.deletePost(post: post)
          })
        }
        
      case .didDeletePost(.success(let id)):
        state.posts.removeAll(where: { $0.id == id })
        return .none
        
      case .didDeletePost(.failure(_)):
        return .none
        
      case .reportPost(let post):
        let reporterId = state.profile.id
        return .task {
          await .didReportPost(TaskResult {
            try await API.reportPost(
              reporterId: reporterId,
              post: post
            )
          })
        }
        
      case .didReportPost(.success(_)):
        return .none
        
      case .didReportPost(.failure(_)):
        return .none
        
      case .blockPost(let post):
        let fromId = state.profile.id
        return .task {
          await .didBlockPost(TaskResult {
            try await API.blockPost(
              post: post,
              fromId: fromId
            )
          })
        }
        
      case .didBlockPost(.success(let post)):
        state.posts.removeAll(where: { $0.id == post.id })
        return .none
        
      case .didBlockPost(.failure(_)):
        return .none
        
      case .blockProfile(let profile):
        let fromId = state.profile.id
        return .task {
          await .didBlockProfile(TaskResult {
            try await API.blockProfile(
              profile: profile,
              fromId: fromId
            )
          })
        }
        
      case .didBlockProfile(.success(let profile)):
        state.posts.removeAll(where: { $0.post.ownerId == profile.id })
        return .none
        
      case .didBlockProfile(.failure(_)):
        return .none
        
      case .settings(_):
        return .none
        
      case .media(_):
        return .none
        
      case .thread(_):
        return .none
      }
    }
    .ifLet(\.settingsState, action: /Action.settings) {
      Settings()
    }
    .ifLet(\.mediaState, action: /Action.media) {
      Media()
    }
  }
}
