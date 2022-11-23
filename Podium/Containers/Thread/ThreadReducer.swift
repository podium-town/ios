//
//  ThreadReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation

let threadReducer = Reducer<ThreadState, ThreadAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .textChanged(let text):
      state.text = text
      state.isSendDisabled = state.text.count < 3
      return .none
      
    case .addComments(let comments):
      state.comments.insert(contentsOf: comments.filter({ $0.ownerId != state.profile.id }), at: 0)
      return .none
      
    case .deletePost(let post):
      return .fireAndForget {
        try await API.deletePost(post: post)
      }
      
    case .send:
      state.isSendDisabled = true
      let comment = PostModel(
        id: UUID().uuidString,
        text: state.text,
        ownerId: state.profile.id,
        createdAt: Date().millisecondsSince1970 / 1000,
        images: [],
        profile: state.profile,
        isLoading: true
      )
      state.text = ""
      state.comments.insert(comment, at: 0)
      return Effect(value: .sended(comment))
      
    case .sended(let comment):
      let postId = state.post.id
      return .task {
        await .didSend(TaskResult {
          try await API.addComment(
            comment: comment,
            postId: postId
          )
        })
      }
      
    case .didSend(.success(let added)):
      state.comments = state.comments.map { comment in
        if comment.id == added.id {
          var mut = comment
          mut.isLoading = false
          return mut
        }
        return comment
      }
      return .none
      
    case .didSend(.failure(let error)):
      return .none
      
    case .getComments:
      state.isLoading = true
      let postId = state.post.id
      return .task {
        await .didGetComments(TaskResult {
          try await API.getComments(
            postId: postId
          )
        })
      }
      
    case .didGetComments(.success(let comments)):
      state.isLoading = false
      state.comments = comments
      return .none
      
    case .didGetComments(.failure(let error)):
      state.isLoading = false
      return .none
    }
  }
)
