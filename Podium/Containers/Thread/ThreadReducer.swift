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
  mediaReducer.optional().pullback(
    state: \.mediaState,
    action: /ThreadAction.media,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .textChanged(let text):
      state.text = text
      state.isSendDisabled = state.text.count < 3
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
      
    case .blockProfile(let profile):
      let fromId = state.fromProfile.id
      return .task {
        await .didBlockProfile(TaskResult {
          try await API.blockProfile(
            profile: profile,
            fromId: fromId
          )
        })
      }
      
    case .didBlockProfile(.success(let profile)):
      return .none
      
    case .didBlockProfile(.failure(let error)):
      return .none
      
    case .blockPost(let post):
      let fromId = state.fromProfile.id
      return .task {
        await .didBlockPost(TaskResult {
          try await API.blockPost(
            post: post,
            fromId: fromId
          )
        })
      }
      
    case .didBlockPost(.success(let profile)):
      return .none
      
    case .didBlockPost(.failure(let error)):
      return .none
      
    case .setLoading(let loading):
      state.isLoading = loading
      return .none
      
    case .addComments(let comments):
      state.isLoading = false
      state.comments.insert(contentsOf: comments, at: 0)
      return .none
      
    case .deletePost(let post):
      return .fireAndForget {
        try await API.deletePost(post: post)
      }
      
    case .deleteComment(let comment):
      state.comments.removeAll(where: { $0.post.id == comment.post.id })
      return .fireAndForget {
        try await API.deleteComment(comment: comment)
      }
      
    case .send:
      let commentId = UUID().uuidString
      state.isSendDisabled = true
      let comment = PostProfileModel(
        id: commentId,
        post: PostModel(
          id: commentId,
          text: state.text,
          ownerId: state.fromProfile.id,
          createdAt: Date().millisecondsSince1970 / 1000,
          images: []
        ),
        profile: state.fromProfile
      )
      state.text = ""
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
      return .none
      
    case .didSend(.failure(let error)):
      return .none
      
    case .openMenu:
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
      
    case .media(_):
      return .none
      
    case .reportPost(post: let post):
      let reporterId = state.fromProfile.id
      return .fireAndForget {
        try await API.reportPost(
          reporterId: reporterId,
          post: post
        )
      }
      
    case .didReportPost(.success(let post)):
      return .none
      
    case .didReportPost(.failure(let error)):
      return .none
      
    case .reportComment(let comment):
      let reporterId = state.fromProfile.id
      return .fireAndForget {
        try await API.reportComment(
          reporterId: reporterId,
          comment: comment
        )
      }
      
    case .didReportComment(.success(let comment)):
      return .none
      
    case .didReportComment(.failure(let comment)):
      return .none
    }
  }
)
