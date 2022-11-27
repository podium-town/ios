//
//  ProfileReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import CoreFoundation

let profileReducer = Reducer<ProfileState, ProfileAction, AppEnvironment>.combine(
  settingsReducer.optional().pullback(
    state: \.settingsState,
    action: /ProfileAction.settings,
    environment: { $0 }
  ),
  threadReducer.optional().pullback(
    state: \.threadState,
    action: /ProfileAction.thread,
    environment: { $0 }
  ),
  mediaReducer.optional().pullback(
    state: \.mediaState,
    action: /ProfileAction.media,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
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
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
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
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      return .none
      
    case .didUnfollow(.failure(let error)):
      state.isPendingFollowing = false
      return .none
      
    case .onMenuOpen:
      return .none
      
    case .deletePost(let post):
      return .task {
        await .didDeletePost(TaskResult {
          try await API.deletePost(
            post: post
          )
        })
      }
      
    case .didDeletePost(.success(let id)):
      state.bannerData = BannerData(
        title: "Deleted",
        detail: "Your post has been deleted.",
        type: .info
      )
      return Effect(value: .getPosts)
      
    case .didDeletePost(.failure(let error)):
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
      
    case .didReportPost(.success(let id)):
      state.bannerData = BannerData(
        title: "Report",
        detail: "Your report has been sent.",
        type: .info
      )
      return .none
      
    case .didReportPost(.failure(let error)):
      return .none
      
    case .dismissBanner:
      state.bannerData = nil
      return .none
      
    case .getPosts:
      state.isLoadingRefreshable = true
      state.isLoading = true
      let id = state.profile.id
      return .task {
        await .didGetPosts(TaskResult {
          try await API.getPosts(followingIds: [id])
        })
      }
      
    case .didGetPosts(.success(let posts)):
      state.isLoading = false
      state.isLoadingRefreshable = false
      state.posts = posts
      if posts.isEmpty {
        state.isEmpty = true
      }
      return .none
      
    case .didGetPosts(.failure(let error)):
      state.isLoadingRefreshable = false
      state.isLoading = false
      return .none
      
    case .presentPicker(let isPresented):
      state.isPickerPresented = isPresented
      return .none
      
    case .presentMedia(let isPresented, let post):
      state.isMediaPresented = isPresented
      if isPresented, let post = post {
        state.mediaState = MediaState(
          post: post
        )
      }
      return .none
      
    case .presentSettings(let isPresented):
      state.isSettingsPresented = isPresented
      if isPresented {
        state.settingsState = SettingsState(
          profile: state.profile
        )
      }
      return .none
      
    case .presentThread(let isPresented, let post):
      state.isThreadPresented = isPresented
      if isPresented, let post = post {
        state.threadState = ThreadState(
          fromProfile: state.fromProfile,
          profile: state.profile,
          profiles: state.profiles,
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
      
    case .thread(_):
      return .none
      
    case .media(_):
      return .none
      
    case .settings(_):
      return .none
    }
  }
)
