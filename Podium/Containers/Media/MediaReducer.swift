//
//  MediaReducer.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import ComposableArchitecture

struct Media: ReducerProtocol {
  typealias State = MediaState
  typealias Action = MediaAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
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
        
      case .didLoadImage(.failure(_)):
        return .none
      }
    }
  }
}
