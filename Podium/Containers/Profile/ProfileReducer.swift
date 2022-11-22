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
    case .getPosts:
      state.isLoadingRefreshable = true
      let id = state.profile.id
      return .task {
        await .didGetPosts(TaskResult {
          try await API.getPosts(followingIds: [id])
        })
      }
      
    case .didGetPosts(.success(let posts)):
      state.isLoadingRefreshable = false
      state.posts = posts.map { post in
        var mut = post
        mut.profile = state.profile
        return mut
      }
      if posts.isEmpty {
        state.isEmpty = true
      }
      return .none
      
    case .didGetPosts(.failure(let error)):
      state.isLoadingRefreshable = false
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
          profile: state.profile,
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
    }
  }
)
