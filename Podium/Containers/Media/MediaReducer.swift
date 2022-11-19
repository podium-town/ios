//
//  MediaReducer.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import ComposableArchitecture

let mediaReducer = Reducer<MediaState, MediaAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .loadImage(let fileId):
      let profileId = state.post.ownerId
      return .task {
        await .didLoadImage(TaskResult {
          try await API.loadImage(
            profileId: profileId,
            fileId: fileId
          )
        })
      }
      
    case .didLoadImage(.success((let fileId, let data))):
      state.loadedImages[fileId] = data
      return .none
      
    case .didLoadImage(.failure(let error)):
      return .none
    }
  }
)
