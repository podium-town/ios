//
//  ProfileReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture

let profileReducer = Reducer<ProfileState, ProfileAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .getPosts:
      let id = state.profile.id
      return .task {
        await .didGetPosts(TaskResult {
          try await environment.api.getPosts(followingIds: [id])
        })
      }
      
    case .didGetPosts(.success(let posts)):
      state.posts = posts
      return .none
      
    case .didGetPosts(.failure(let error)):
      return .none
    }
  }
)
