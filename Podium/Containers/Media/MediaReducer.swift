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
    case .loadImage(let url):
      let profileId = state.post.post.ownerId
      return .task {
        await .didLoadImage(TaskResult {
          try await API.getImage(
            url: url
          )
        })
      }
      
    case .didLoadImage(.success((let url, let data))):
      state.loadedImages?[url] = data
      return .none
      
    case .didLoadImage(.failure(let error)):
      return .none
    }
  }
)
