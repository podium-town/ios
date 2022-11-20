//
//  ThreadReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine

let threadReducer = Reducer<ThreadState, ThreadAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .textChanged(let text):
      state.text = text
      state.isSendDisabled = state.text.count < 3
      return .none
      
    case .send:
      state.isSendDisabled = true
      let text = state.text
      state.text = ""
      if let postId = state.post?.id {
        let ownerId = state.profile.id
        return .task {
          await .didSend(TaskResult {
            try await API.addComment(
              text: text,
              ownerId: ownerId,
              postId: postId
            )
          })
        }
      } else {
        return .none
      }
      
    case .didSend(.success(let post)):
      return .none
      
    case .didSend(.failure(let error)):
      return .none
      
    case .getComments:
      if let post = state.post,
         let comments = post.comments,
         !comments.isEmpty {
        let postId = post.id
        return .task {
          await .didGetComments(TaskResult {
            try await API.getComments(
              postId: postId
            )
          })
        }
      }
      return .none
      
    case .didGetComments(.success(let comments)):
      state.comments = comments
      return .none
      
    case .didGetComments(.failure(let error)):
      return .none
    }
  }
)
