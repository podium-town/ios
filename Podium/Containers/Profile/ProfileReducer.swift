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
      
    case .presentSettings(let isPresented):
      state.isSettingsPresented = isPresented
      if isPresented {
        state.settingsState = SettingsState(
          profile: state.profile
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
    }
  }
)
